terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Get tenant / caller info (used for some defaults)
data "azurerm_client_config" "current" {}

# Parse the full databricks resource id passed in as a var
locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, var.databricks_resource_id)[0]
  resource_group            = regex(local.resource_regex, var.databricks_resource_id)[1]
  databricks_workspace_name = regex(local.resource_regex, var.databricks_resource_id)[2]
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  prefix                    = replace(replace(replace(lower(local.resource_group), "rg", ""), "-", ""), "_", "")
}

# Resource group and workspace lookup
data "azurerm_resource_group" "this" {
  name = local.resource_group
}

data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

locals {
  databricks_workspace_host = data.azurerm_databricks_workspace.this.workspace_url
}

# Azure provider using the subscription parsed from the workspace resource id
provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

# Workspace-scoped Databricks provider — will pick up auth from environment
provider "databricks" {
  host = local.databricks_workspace_host
}

# Account-level Databricks provider (alias) — will pick up auth from environment
provider "databricks" {
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.account_id
  # auth_type omitted so provider uses environment-based auth (Azure CLI / MSI / SP creds)
}

# ---------------------------------------------------------
# Module: create metastore, access connector, storage, users/groups/SPs
# ---------------------------------------------------------
module "metastore_and_users" {
  source                    = "./modules/metastore-and-users"

  # inputs derived above
  subscription_id           = local.subscription_id
  databricks_workspace_name = local.databricks_workspace_name
  resource_group            = local.resource_group
  account_id                = var.account_id
  prefix                    = local.prefix
  aad_groups                = var.aad_groups

  # Access connector/managed identity
  databricks_access_connector_name = var.databricks_access_connector_name
  access_connector_identity_type   = var.access_connector_identity_type
  identity_ids                     = var.identity_ids
  access_connector_tags            = var.access_connector_tags

  # Storage account module inputs (pass-through)
  storage_account_name             = var.storage_account_name
  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  storage_account_kind             = var.storage_account_kind
  storage_account_access_tier      = var.storage_account_access_tier
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_rg_name  = var.log_analytics_workspace_rg_name

  # Optional: any other module inputs you expose
  # ...
}

# Combine users + service principals map into one lookup for membership population
locals {
  merged_user_sp = merge(
    lookup(module.metastore_and_users, "databricks_users", {}),
    lookup(module.metastore_and_users, "databricks_sps", {})
  )
}

locals {
  aad_groups = toset(var.aad_groups)
}

# Read group members from Azure AD
data "azuread_group" "this" {
  for_each     = local.aad_groups
  display_name = each.value
}

# Put users and service principals into their respective Databricks groups
resource "databricks_group_member" "this" {
  provider = databricks.azure_account

  for_each = toset(flatten([
    for group, details in data.azuread_group.this : [
      for member in details["members"] : jsonencode({
        group  = module.metastore_and_users.databricks_groups[details["object_id"]]
        member = local.merged_user_sp[member]
      })
    ]
  ]))

  group_id   = jsondecode(each.value).group
  member_id  = jsondecode(each.value).member

  depends_on = [module.metastore_and_users]
}

# Add the Databricks account group principals to the workspace with appropriate permissions
resource "databricks_mws_permission_assignment" "workspace_user_groups" {
  for_each     = data.azuread_group.this
  provider     = databricks.azure_account
  workspace_id = module.metastore_and_users.databricks_workspace_id
  principal_id = module.metastore_and_users.databricks_groups[each.value["object_id"]]
  permissions  = each.key == "account_unity_admin" ? ["ADMIN"] : ["USER"]
  depends_on   = [databricks_group_member.this]
}

# -----------------------
# Workspace resources: external storage, catalog, schemas, grants
# -----------------------

# Create a container in storage account to be used by dev catalog as root storage
resource "azurerm_storage_container" "dev_catalog" {
  name                  = "dev-catalog"
  storage_account_id    = module.metastore_and_users.storage_account_id
  container_access_type = "private"
}

# Storage credential using the managed identity (access connector) created in the module
resource "databricks_storage_credential" "external_mi" {
  name = "external_location_mi_credential"

  azure_managed_identity {
    access_connector_id = module.metastore_and_users.azurerm_databricks_access_connector_id
  }

  owner      = "account_unity_admin"
  comment    = "Storage credential for external locations"
  depends_on = [databricks_mws_permission_assignment.workspace_user_groups]
}

# Create external location to be used as root storage by dev catalog
resource "databricks_external_location" "dev_location" {
  name            = "dev-catalog-external-location"
  url             = format("abfss://%s@%s.dfs.core.windows.net",
                      azurerm_storage_container.dev_catalog.name,
                      module.metastore_and_users.storage_account_name)
  credential_name = databricks_storage_credential.external_mi.id
  owner           = "account_unity_admin"
  comment         = "External location used by dev catalog as root storage"
}

# Create dev environment catalog
resource "databricks_catalog" "dev" {
  metastore_id = module.metastore_and_users.metastore_id
  name         = "dev_catalog"
  comment      = "this catalog is for dev env"
  owner        = "account_unity_admin"
  storage_root = databricks_external_location.dev_location.url

  properties = {
    purpose = "dev"
  }

  depends_on = [databricks_external_location.dev_location]
}

# Grants on dev catalog
resource "databricks_grants" "dev_catalog" {
  catalog = databricks_catalog.dev.name

  grant {
    principal  = "data_engineer"
    privileges = ["USE_CATALOG"]
  }

  grant {
    principal  = "data_scientist"
    privileges = ["USE_CATALOG"]
  }

  grant {
    principal  = "data_analyst"
    privileges = ["USE_CATALOG"]
  }
}

# Bronze schema
resource "databricks_schema" "bronze" {
  catalog_name = databricks_catalog.dev.id
  name         = "bronze"
  owner        = "account_unity_admin"
  comment      = "this database is for bronze layer tables/views"
}

resource "databricks_grants" "bronze" {
  schema = databricks_schema.bronze.id

  grant {
    principal  = "data_engineer"
    privileges = ["USE_SCHEMA", "CREATE_FUNCTION", "CREATE_TABLE", "EXECUTE", "MODIFY", "SELECT"]
  }
}

# Silver schema
resource "databricks_schema" "silver" {
  catalog_name = databricks_catalog.dev.id
  name         = "silver"
  owner        = "account_unity_admin"
  comment      = "this database is for silver layer tables/views"
}

resource "databricks_grants" "silver" {
  schema = databricks_schema.silver.id

  grant {
    principal  = "data_engineer"
    privileges = ["USE_SCHEMA", "CREATE_FUNCTION", "CREATE_TABLE", "EXECUTE", "MODIFY", "SELECT"]
  }

  grant {
    principal  = "data_scientist"
    privileges = ["USE_SCHEMA", "SELECT"]
  }
}

# Gold schema
resource "databricks_schema" "gold" {
  catalog_name = databricks_catalog.dev.id
  name         = "gold"
  owner        = "account_unity_admin"
  comment      = "this database is for gold layer tables/views"
}

resource "databricks_grants" "gold" {
  schema = databricks_schema.gold.id

  grant {
    principal  = "data_engineer"
    privileges = ["USE_SCHEMA", "CREATE_FUNCTION", "CREATE_TABLE", "EXECUTE", "MODIFY", "SELECT"]
  }

  grant {
    principal  = "data_scientist"
    privileges = ["USE_SCHEMA", "SELECT"]
  }

  grant {
    principal  = "data_analyst"
    privileges = ["USE_SCHEMA", "SELECT"]
  }
}

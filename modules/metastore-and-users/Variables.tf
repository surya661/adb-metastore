variable "subscription_id" {
  description = "Azure subscription id."
  type        = string
}

variable "resource_group" {
  description = "Name of the resource group that contains the Databricks workspace and other resources."
  type        = string
}

variable "databricks_workspace_name" {
  description = "Name of the existing Databricks workspace to attach to the metastore."
  type        = string
}

variable "account_id" {
  description = "Databricks account id for account-level provider actions (used with databricks provider alias)."
  type        = string
}

variable "prefix" {
  description = "Prefix used for naming resources (used to name container, etc.)."
  type        = string
  default     = "uc"
}

# Databricks Access Connector (managed identity) settings
variable "databricks_access_connector_name" {
  description = "Name for the azurerm_databricks_access_connector resource (managed identity)."
  type        = string
}

variable "access_connector_identity_type" {
  description = "Identity type for the access connector. Example: 'SystemAssigned' or 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "If using UserAssigned identities, list of user assigned identity resource ids to attach to the access connector."
  type        = list(string)
  default     = []
}

variable "access_connector_tags" {
  description = "Tags to apply to the managed identity / access connector."
  type        = map(string)
  default     = {}
}

# Storage account module inputs (module ../storage-account)
variable "storage_account_name" {
  description = "Storage account name to create (must be globally unique)."
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account SKU tier for the module (Standard/Premium)."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account (LRS, ZRS, GRS, RA-GRS, etc.)."
  type        = string
  default     = "LRS"
}

variable "storage_account_kind" {
  description = "Storage account kind e.g. StorageV2, BlobStorage, etc."
  type        = string
  default     = "StorageV2"
}

variable "storage_account_access_tier" {
  description = "Access tier for blob storage (Hot/Cool)."
  type        = string
  default     = "Hot"
}

variable "cross_tenant_replication_enabled" {
  description = "Enable cross-tenant replication for the storage account (if supported by your module/workflow)."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_name" {
  description = "Optional: Log Analytics workspace name to link to storage account module (if your module supports it)."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_rg_name" {
  description = "Optional: Resource Group name of the Log Analytics workspace."
  type        = string
  default     = ""
}

# Metastore configuration
variable "metastore_name" {
  description = "Name of the Databricks Unity Catalog metastore."
  type        = string
  default     = "primary"
}

variable "metastore_owner" {
  description = "Owner principal for the metastore (for example an account group or user)."
  type        = string
  default     = "account_unity_admin"
}

variable "force_destroy_metastore" {
  description = "Whether to force_destroy the databricks metastore resource."
  type        = bool
  default     = true
}

variable "default_namespace" {
  description = "Default namespace (catalog/schema) to create or set on the workspace."
  type        = string
  default     = "main"
}

# Role assignment
variable "storage_role_definition_name" {
  description = "Role to grant to the access connector over the storage account (e.g. 'Storage Blob Data Contributor')."
  type        = string
  default     = "Storage Blob Data Contributor"
}

# Azure AD / Account users & groups
variable "aad_groups" {
  description = "List of Azure AD group display names to sync into Databricks account."
  type        = list(string)
  default     = []
}

# User / service principal lifecycle options
variable "disable_as_user_deletion" {
  description = "Pass to databricks_user.disable_as_user_deletion. When true users are not deleted as user objects."
  type        = bool
  default     = true
}

# Databricks account-level provider auth type (for alias provider)
variable "account_auth_type" {
  description = "Auth type used for the account-level databricks provider (e.g. 'azure-cli')."
  type        = string
  default     = "azure-cli"
}

# Optional: allow overriding databricks accounts host if needed (rare)
variable "databricks_accounts_host" {
  description = "The host to use for account-level databricks provider. Default for Azure is https://accounts.azuredatabricks.net"
  type        = string
  default     = "https://accounts.azuredatabricks.net"
}

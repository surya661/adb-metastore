#Create Azure Key Vault using Terraform:
provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }
}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}
 
resource "azurerm_key_vault" "this" {
  name                        = "db-keyvault"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
}
 
 
#2. Configure Key Vault Access Policies:
data "azuread_service_principal" "terraform-sp" {
  display_name = "terraform-app"
}

resource "azurerm_key_vault_access_policy" "terraform-principal" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.terraform-sp.id

  key_permissions = [
    "Get", "List"
  ]
}

#3. Create Databricks Secret Scope backed by Azure Key Vault:
resource "databricks_secret_scope" "example_scope" {
  name         = "my-keyvault-scope"
  backend_type = "AZURE_KEYVAULT"
  keyvault_metadata {
    resource_id = azurerm_key_vault.this.id
    dns_name    = azurerm_key_vault.this.vault_uri
  }
}
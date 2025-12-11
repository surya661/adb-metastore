output "databricks_workspace_host" {
  description = "The workspace host URL for the Databricks workspace attached to the metastore."
  value       = local.databricks_workspace_host
}

output "databricks_workspace_id" {
  description = "The Databricks workspace id."
  value       = local.databricks_workspace_id
}

output "access_connector_id" {
  description = "Resource ID of the azurerm_databricks_access_connector created for Unity Catalog."
  value       = azurerm_databricks_access_connector.unity.id
}

output "access_connector_principal_id" {
  description = "Principal ID of the managed identity inside the access connector."
  value       = azurerm_databricks_access_connector.unity.identity[0].principal_id
}

output "role_assignment_id" {
  description = "Role assignment id that grants Storage Blob Data Contributor to the access connector."
  value       = azurerm_role_assignment.mi_data_contributor.id
}

output "storage_account_id" {
  description = "Resource ID of the storage account used for Unity Catalog root storage."
  value       = module.unity_catalog_storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account used for Unity Catalog root storage."
  value       = module.unity_catalog_storage_account.storage_account_name
}

output "storage_container_id" {
  description = "ID of the storage container created for Unity Catalog root storage."
  value       = azurerm_storage_container.unity_catalog.id
}

output "storage_container_name" {
  description = "Name of the storage container created for Unity Catalog root storage."
  value       = azurerm_storage_container.unity_catalog.name
}

output "databricks_metastore_id" {
  description = "ID of the Databricks Unity Catalog metastore."
  value       = databricks_metastore.this.id
}

output "databricks_metastore_name" {
  description = "Name of the Databricks Unity Catalog metastore."
  value       = databricks_metastore.this.name
}

output "databricks_metastore_storage_root" {
  description = "Storage root (abfss path) used by the metastore."
  value       = databricks_metastore.this.storage_root
}

output "metastore_data_access_id" {
  description = "ID of the databricks_metastore_data_access resource that binds the managed identity to the metastore."
  value       = databricks_metastore_data_access.first.id
}

output "metastore_assignment_id" {
  description = "ID of the metastore assignment which attaches the workspace to the metastore."
  value       = databricks_metastore_assignment.this.id
}

output "default_namespace" {
  description = "Default namespace value set in the workspace."
  value       = var.default_namespace
}

# Maps and lists for account-level objects created/managed
output "databricks_groups_map" {
  description = "Map of synced Databricks group ids keyed by Azure AD group display name."
  value = {
    for k, g in databricks_group.this :
    k => g.id
  }
}

output "databricks_users_map" {
  description = "Map of Databricks user ids keyed by Azure AD user object id."
  value = {
    for k, u in databricks_user.this :
    k => u.id
  }
}

output "databricks_service_principals_map" {
  description = "Map of Databricks service principal ids keyed by Azure AD service principal object id."
  value = {
    for k, sp in databricks_service_principal.sp :
    k => sp.id
  }
}

output "account_admin_users_map" {
  description = "Map of Databricks user ids promoted to account_admin (keyed by Azure AD user object id)."
  value = {
    for k, u in databricks_user_role.account_admin :
    k => u.user_id
  }
}

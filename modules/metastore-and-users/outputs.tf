#for azurerm_databricks_access_connector
output "azurerm_databricks_access_connector_id" {
  description = "The Resource ID of the Databricks Access Connector."
  value = azurerm_databricks_access_connector.unity.id
}
output "identity_type" {
  description = "The type of Managed Service Identity assigned to the Access Connector."
  value       = azurerm_databricks_access_connector.unity.identity[0].type
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Service Identity."
  value       = azurerm_databricks_access_connector.unity.identity[0].principal_id
}

output "tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Service Identity."
  value       = azurerm_databricks_access_connector.unity.identity[0].tenant_id
}

output "identity_ids" {
  description = "The list of User Assigned Managed Identity IDs assigned."
  value       = try(azurerm_databricks_access_connector.unity.identity[0].identity_ids, [])
}


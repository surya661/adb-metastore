variable "subscription_id" {
  description = "Azure subscription id"
}
variable "databricks_workspace_name" {
  description = "Azure databricks workspace name"
}
variable "resource_group" {
  description = "Azure resource group"
}
variable "aad_groups" {
  description = "List of AAD groups that you want to add to Databricks account"
  type        = list(string)
}
variable "account_id" {
  description = "Azure databricks account id"
}
variable "prefix" {
  description = "Prefix to be used with resouce names"
}
#variables for azurerm_databricks_access_connector
variable "databricks_access_connector_name" {
  description = "The name of the Databricks Access Connector."
  type = string
  
}
variable "access_connector_identity_type" {
  description = "The type of Managed Service Identity (SystemAssigned, UserAssigned, or both)."
  type        = string
  default     = "SystemAssigned"
}
variable "access_connector_tags" {
  description = "A mapping of tags to assign to the resource."
  type = map(string)
  default = {}
  
}
variable "identity_ids" {
  description = " Specifies a list of User Assigned Managed Identity IDs to be assigned to the Databricks Access Connector. Only one User Assigned Managed Identity ID is supported per Databricks Access Connector resource."
  type = list(string)
  default = []
  
}
#variables for azurerm_storage_account
variable "storage_account_name" {
  description = "Name of the Azure Storage Account."
  type = string
}
variable "storage_account_tier" {
  description = "Performance tier for the Storage Account (Standard or Premium)."
  type = string
  
}
variable "storage_account_replication_type" {
  description = "Replication type for the Storage Account (e.g., LRS, GRS, RAGRS, ZRS)."
  type = string
  
}
variable "storage_account_tags" {
  description = "Tags to associate with the Storage Account."
  type = map(string)
  default = {}
  
}
variable "storage_account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2."
  type = string
  default     = "StorageV2"
}
variable "storage_account_access_tier" {
  description = "Access tier for Blob Storage (Hot or Cool)."
  type        = string
  default     = "Hot"
  
}
variable "provisioned_billing_model_version" {
  description = "Specifies the version of the provisioned billing model (e.g. when account_kind = 'FileStorage' for Storage File). Possible value is V2."
  type = string
}
variable "cross_tenant_replication_enabled" {
  description = "Should cross Tenant replication be enabled? Defaults to false."
  type = bool
  default = false
  
}
variable "log_analytics_workspace_name" {
  description = "log analytics workspace name"
  type = string
}
variable "log_analytics_workspace_rg_name" {
  description = "log analytics workspace rg name"
  type = string
  
}
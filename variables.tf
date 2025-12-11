# Required: Databricks workspace resource ID
variable "databricks_resource_id" {
  description = "Full Azure resource ID of the Databricks workspace used for Unity Catalog."
  type        = string
}
# Required: Databricks Account ID
# Used for account-level operations such as SCIM and UC metastore creation.
variable "account_id" {
  description = "The Databricks account ID used by the account-level provider."
  type        = string
}
# AAD Groups to sync into Databricks (list of display names)
# These groups must already exist in Azure AD.
variable "aad_groups" {
  description = "List of Azure AD group display names to onboard into the Databricks account."
  type        = list(string)
  default     = []
}
# Required inputs for the metastore-and-users module:
# Access Connector (aka Managed Identity for UC)
variable "databricks_access_connector_name" {
  description = "Name of the Databricks access connector managed identity."
  type        = string
}

variable "access_connector_identity_type" {
  description = "Managed identity type: SystemAssigned or UserAssigned."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of User Assigned Identity resource IDs (only used when identity_type includes UserAssigned)."
  type        = list(string)
  default     = []
}

variable "access_connector_tags" {
  description = "Tags to apply to the Databricks access connector."
  type        = map(string)
  default     = {}
}
# Storage account configuration for UC root storage
# (Passed directly to the storage-account module)
variable "storage_account_name" {
  description = "Name of the storage account for Unity Catalog root storage."
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account performance tier (Standard/Premium)."
  type        = string
}

variable "storage_account_replication_type" {
  description = "Replication type (LRS/ZRS/GRS/etc)."
  type        = string
}

variable "storage_account_kind" {
  description = "Storage account kind, e.g., StorageV2."
  type        = string
}

variable "storage_account_access_tier" {
  description = "Access tier for storage account (Hot/Cool)."
  type        = string
}

variable "cross_tenant_replication_enabled" {
  description = "Enable or disable cross-tenant replication."
  type        = bool
  default     = false
}
# Optional Log Analytics inputs for the storage-account module
variable "log_analytics_workspace_name" {
  description = "Name of Log Analytics Workspace for diagnostic settings."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_rg_name" {
  description = "Resource group of the Log Analytics workspace."
  type        = string
  default     = ""
}

# ---------------------------------------------------------
# PRINCIPAL NAMES FOR GRANTS (optional tuning)
# ---------------------------------------------------------
variable "data_engineer_principal" {
  description = "Principal name for data engineers."
  type        = string
  default     = "data_engineer"
}

variable "data_scientist_principal" {
  description = "Principal name for data scientists."
  type        = string
  default     = "data_scientist"
}

variable "data_analyst_principal" {
  description = "Principal name for data analysts."
  type        = string
  default     = "data_analyst"
}

# ---------------------------------------------------------
# DEV Catalog configuration
# ---------------------------------------------------------
variable "dev_catalog_container_name" {
  description = "Name of the ADLS container that backs the dev catalog."
  type        = string
  default     = "dev-catalog"
}

variable "dev_catalog_name" {
  description = "Unity Catalog catalog name for the dev environment."
  type        = string
  default     = "dev_catalog"
}

# ---------------------------------------------------------
# Root metastore module prefix (derived from RG but overridable)
# ---------------------------------------------------------
variable "prefix" {
  description = "Prefix used for naming resources. Usually auto-generated but may be overridden."
  type        = string
  default     = null
}

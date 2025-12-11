
variable "name" {
  description = <<EOT
The name of the storage account. 
Must be 3-24 characters, lowercase letters and numbers only. 
No hyphens or special characters allowed.
EOT
  type = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24
    error_message = "The storage account name must be between 3 and 24 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "The storage account name must only contain lowercase letters and numbers; no hyphens or special characters."
  }
}

variable "resource_group_name" {
  description = "A name between 1 and 90 characters, using only letters, digits, underscores, hyphens, periods, and parentheses. Cannot end with a period."
  type        = string

  validation {
    condition = (
      length(var.resource_group_name) >= 1                                  # At least 1 char
      && length(var.resource_group_name) <= 90                             # No more than 90 chars
      && can(regex("^[A-Za-z0-9_.\\-()]+$", var.resource_group_name))       # Valid characters
      && !endswith(var.resource_group_name, ".")                           # Cannot end with a period
    )
    error_message = "Name must be 1-90 chars, using only letters, digits, underscores, hyphens, periods, and parentheses, and cannot end with a period."
  }
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Location where resources will be created on"
  validation {
    condition = contains(["eastus", "eastus2", "southcentralus", "westus2", "westus3",
      "centralus", "northcentralus", "westus", "southafricanorth",
      "australiacentral", "australiacentral2", "australiaeast",
      "australiasoutheast", "brazilsouth", "brazilsoutheast",
      "canadacentral", "canadaeast", "centralindia", "japaneast",
      "japanwest", "koreacentral", "koreasouth", "northeurope",
      "norwayeast", "norwaywest", "southindia", "swedencentral",
      "switzerlandnorth", "switzerlandwest", "uaenorth", "uksouth",
      "ukwest", "westcentralus", "westeurope", "southeastasia",
      "eastasia", "francecentral", "francesouth", "germanywestcentral",
      "germanynorth", "northgermany", "southgermany"
    ], var.location)
    error_message = "Invalid Azure region specified for 'location'. Please provide a valid Azure region, such as 'eastus2', 'centralus', or 'westus3'."
  }
}


variable "access_tier" {
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are 'Hot', 'Cool', 'Cold' and 'Premium'."
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool", "Cold", "Premium"], var.access_tier)
    error_message = "access_tier must be one of: Hot, Cool, Cold, Premium."
  }
}

variable "account_kind" {
  description = "(Optional) Kind of storage account. Valid: 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', 'StorageV2'."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "account_replication_type" {
  description = "(Required) Defines replication type. Valid: 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', 'RAGZRS'."
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_tier" {
  description = "(Required) Tier to use for the storage account. Valid: 'Standard', 'Premium'. For BlockBlobStorage/FileStorage only Premium is valid."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be either Standard or Premium."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "(Optional) Allow or disallow nested items to be public. Defaults to false."
  type        = bool
  default     = false
}

variable "blob_properties" {
  description = <<EOT
(Optional) Advanced blob service settings.
See documentation for nested block details.
EOT
  type = object({
    change_feed_enabled                = optional(bool)
    change_feed_retention_in_days      = optional(number)
    default_service_version            = optional(string)
    last_access_time_enabled           = optional(bool)
    versioning_enabled                 = optional(bool, true)
    container_delete_retention_policy  = optional(object({
      days = optional(number, 7)
    }), { days = 7 })
    cors_rule                          = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string) # Valid: DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT, PATCH
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
    delete_retention_policy            = optional(object({
      days = optional(number, 7)
    }), { days = 7 })
    diagnostic_settings                = optional(map(object({
      name                                 = optional(string, null)
      log_categories                       = optional(set(string), [])
      log_groups                           = optional(set(string), ["allLogs"])
      metric_categories                    = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type       = optional(string, "Dedicated")
      workspace_resource_id                = optional(string, null)
      resource_id                          = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                       = optional(string, null)
      marketplace_partner_resource_id      = optional(string, null)
    })), {})
    restore_policy                      = optional(object({
      days = number
    }))
  })
  default = null
}

variable "cross_tenant_replication_enabled" {
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "diagnostic_settings_blob" {
  description = "A map of diagnostic settings to create on Blob Storage."
  type = map(object({
    name                                 = optional(string, null)
    log_categories                       = optional(set(string), [])
    log_groups                           = optional(set(string), ["allLogs"])
    metric_categories                    = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type       = optional(string, "Dedicated")
    workspace_resource_id                = optional(string, null)
    storage_account_resource_id          = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                       = optional(string, null)
    marketplace_partner_resource_id      = optional(string, null)
  }))
  default = {}
}

variable "diagnostic_settings_file" {
  description = "A map of diagnostic settings to create on Azure Files Storage."
  type = map(object({
    name                                 = optional(string, null)
    log_categories                       = optional(set(string), [])
    log_groups                           = optional(set(string), ["allLogs"])
    metric_categories                    = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type       = optional(string, "Dedicated")
    workspace_resource_id                = optional(string, null)
    storage_account_resource_id          = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                       = optional(string, null)
    marketplace_partner_resource_id      = optional(string, null)
  }))
  default = {}
}

variable "diagnostic_settings_storage_account" {
  description = "A map of diagnostic settings on the Storage Account."
  type = map(object({
    name                                 = optional(string, null)
    log_categories                       = optional(set(string), [])
    log_groups                           = optional(set(string), ["allLogs"])
    metric_categories                    = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type       = optional(string, "Dedicated")
    workspace_resource_id                = optional(string, null)
    storage_account_resource_id          = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                       = optional(string, null)
    marketplace_partner_resource_id      = optional(string, null)
  }))
  default = {}
}

variable "https_traffic_only_enabled" {
  description = "(Optional) Boolean flag which forces HTTPS if enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
  description = "(Optional) Enable infrastructure encryption. Defaults to false."
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? Changes force resource recreation."
  type        = bool
  default     = null
}

variable "large_file_share_enabled" {
  description = "(Optional) Is Large File Share Enabled?"
  type        = bool
  default     = null
}

variable "min_tls_version" {
  description = "(Optional) Minimum supported TLS version: 'TLS1_0', 'TLS1_1', 'TLS1_2'."
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "network_rules" {
  description = <<EOT
Network rules for storage account. Default value blocks all public access.
Set to null to disable network rules.
EOT
  type = object({
    bypass                     = optional(set(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
    private_link_access        = optional(list(object({
      endpoint_resource_id     = string
      endpoint_tenant_id       = optional(string)
    })))
    timeouts                   = optional(object({
      create                   = optional(string)
      delete                   = optional(string)
      read                     = optional(string)
      update                   = optional(string)
    }))
  })
  default = {}
}

variable "private_endpoints" {
  description = "A map of private endpoints to create on the resource."
  type = map(object({
    name                                     = optional(string, null)
    role_assignments                         = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
    lock           = optional(object({ 
        kind = string 
        name = optional(string, null) 
    }), null)
    tags           = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations                       = optional(
        map(object({
            name              = string
            private_ip_address = string
        })))
  }))
  default = {}
}

variable "private_endpoints_manage_dns_zone_group" {
  description = "Whether to manage private DNS zone groups with this module."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "(Optional) Is public network access enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "storage_data_lake_gen2_filesystems" {
  description = "A map of Data Lake Gen2 filesystems to be managed."
  type = map(object({
    default_encryption_scope = optional(string)
    group                    = optional(string)
    name                     = string
    owner                    = optional(string)
    properties               = optional(map(string))
    ace                      = optional(set(object({
      id          = optional(string)
      permissions = string
      scope       = optional(string)
      type        = string
    })))
    timeouts                 = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default = {}
}

variable "log_analytics_workspace_rg_name" {
  description = ""
  type        = string


}

variable "log_analytics_workspace_name" {
  description = ""
  type        = string


}
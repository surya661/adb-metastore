module "avm-res-storage-storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  # insert the 3 required variables here
  name = var.name
  location = var.location
  resource_group_name = var.resource_group_name

  # Optional variables
  access_tier = var.access_tier
  account_kind = var.account_kind
  account_replication_type =var.account_replication_type
  account_tier = var.account_tier

  # Security settings
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
  https_traffic_only_enabled =  var.https_traffic_only_enabled
  infrastructure_encryption_enabled =  var.infrastructure_encryption_enabled
  min_tls_version = var.min_tls_version
  shared_access_key_enabled = true

  # DataLake flag
  is_hns_enabled = var.is_hns_enabled
  storage_data_lake_gen2_filesystems = var.is_hns_enabled ? var.storage_data_lake_gen2_filesystems : {}  
  
  # Blob Properties
  //blob_properties = var.blob_properties
  blob_properties = {
    change_feed_enabled = try(var.blob_properties.change_feed_enabled,null)
    change_feed_retention_in_days = try(var.blob_properties.change_feed_retention_in_days,null)
    default_service_version = try(var.blob_properties.default_service_version,null)
    last_access_time_enabled = try(var.blob_properties.last_access_time_enabled,false)
    versioning_enabled = try(var.blob_properties.change_feed_enabled,false)

    container_delete_retention_policy = try(var.blob_properties.container_delete_retention_policy,null)
    cors_rule = try(var.blob_properties.cors_rule,null)
    delete_retention_policy = try(var.blob_properties.delete_retention_policy,null)
    /*diagnostic_settings = {
        blob11 = {
          name                                     = "diag"
          workspace_resource_id                    = data.azurerm_log_analytics_workspace.law.id      
          log_groups = ["allLogs"]          
          metric_categories                        = ["AllMetrics"]
          log_analytics_destination_type          = "Dedicated"
        }
    }*/

  }

  # File Shares
  large_file_share_enabled =  var.large_file_share_enabled

  # Networking settings
  public_network_access_enabled = var.public_network_access_enabled
  network_rules = var.network_rules
  private_endpoints = var.private_endpoints
  private_endpoints_manage_dns_zone_group =  false

  # Module telemertry for this module
  enable_telemetry =  false

  depends_on = [ 
    azurerm_role_assignment.storage_blob_data_owner,
    time_sleep.role_assignment_sleep
   ]
}


data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg_name
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "this" {
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {

  count = (var.is_hns_enabled) ? 1 : 0 

  scope  = data.azurerm_resource_group.rg.id
  role_definition_name = "storage blob data owner"
  principal_id = data.azurerm_client_config.this.object_id
}

resource "time_sleep" "role_assignment_sleep" {

  count = (var.is_hns_enabled) ? 1 : 0 

  create_duration = "120s"

  triggers = {
    role_assignment = azurerm_role_assignment.storage_blob_data_owner[0].id
  }
}
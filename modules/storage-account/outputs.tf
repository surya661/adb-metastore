output "resource" {
  value       = module.avm-res-storage-storageaccount.resource
  description = "This is the full output for the storage account."
}

output "resource_id" {
  value       = module.avm-res-storage-storageaccount.resource_id
  description = "The resource Id of the storage account"
}

output "storage_account_name" {
  value       = module.avm-res-storage-storageaccount.name
  description = "The name of the storage account"
}
output "storage_account_id" {
  value = module.avm-res-storage-storageaccount.resource.id

  description = "storage account id"
  
}
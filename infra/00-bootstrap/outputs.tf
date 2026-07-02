output "bootstrap_resource_group_name" {
  description = "Name of the bootstrap resource group."
  value       = azurerm_resource_group.bootstrap.name
}

output "storage_account_name" {
  description = "Name of the Terraform state storage account."
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  description = "Resource ID of the Terraform state storage account."
  value       = azurerm_storage_account.tfstate.id
}

output "tfstate_container_name" {
  description = "Name of the Terraform state blob container."
  value       = azurerm_storage_container.tfstate.name
}

output "platform_dev_resource_group_name" {
  description = "Name of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform_dev.name
}

output "platform_dev_resource_group_id" {
  description = "Resource ID of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform_dev.id
}

output "platform_location" {
  description = "Azure location of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform_dev.location
}

output "platform_dev_tags" {
  description = "Common tags applied to the persistent dev platform resource group."
  value       = local.platform_dev_tags
}

output "resource_group_name" {
  description = "Name of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform.name
}

output "resource_group_id" {
  description = "Resource ID of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform.id
}

output "location" {
  description = "Azure location of the persistent dev platform resource group."
  value       = azurerm_resource_group.platform.location
}

output "common_tags" {
  description = "Common tags applied by the foundation layer."
  value       = local.common_tags
}


output "vnet_id" {
  description = "Resource ID of the platform virtual network."
  value       = azurerm_virtual_network.platform.id
}

output "vnet_name" {
  description = "Name of the platform virtual network."
  value       = azurerm_virtual_network.platform.name
}

output "vnet_address_space" {
  description = "Address space of the platform virtual network."
  value       = azurerm_virtual_network.platform.address_space
}

output "subnet_ids" {
  description = "Map of subnet keys to subnet resource IDs."
  value = {
    for key, subnet in azurerm_subnet.platform : key => subnet.id
  }
}

output "subnet_cidrs" {
  description = "Map of subnet keys to subnet CIDR blocks."
  value = {
    for key, subnet in local.subnets : key => subnet.address_prefixes
  }
}

output "pod_cidr" {
  description = "Future AKS pod CIDR for Azure CNI Overlay."
  value       = local.kubernetes_network.pod_cidr
}

output "service_cidr" {
  description = "Future AKS service CIDR."
  value       = local.kubernetes_network.service_cidr
}

output "dns_service_ip" {
  description = "Future AKS DNS service IP."
  value       = local.kubernetes_network.dns_service_ip
}


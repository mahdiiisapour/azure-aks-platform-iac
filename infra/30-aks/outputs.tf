output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.platform.name
}

output "cluster_id" {
  description = "AKS cluster resource ID."
  value       = azurerm_kubernetes_cluster.platform.id
}

output "node_resource_group_name" {
  description = "Automatically managed AKS node resource group name."
  value       = azurerm_kubernetes_cluster.platform.node_resource_group
}

output "kubernetes_version" {
  description = "Effective AKS Kubernetes version selected by Azure."
  value       = azurerm_kubernetes_cluster.platform.kubernetes_version
}

output "api_server_public_access" {
  description = "Whether this lab cluster uses a public API endpoint."
  value       = !azurerm_kubernetes_cluster.platform.private_cluster_enabled
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity federation."
  value       = azurerm_kubernetes_cluster.platform.oidc_issuer_url
}

output "control_plane_identity_id" {
  description = "Control-plane user-assigned identity resource ID."
  value       = azurerm_user_assigned_identity.control_plane.id
}

output "control_plane_identity_principal_id" {
  description = "Control-plane user-assigned identity principal ID."
  value       = azurerm_user_assigned_identity.control_plane.principal_id
}

output "kubelet_identity_id" {
  description = "Kubelet user-assigned identity resource ID."
  value       = azurerm_user_assigned_identity.kubelet.id
}

output "kubelet_identity_principal_id" {
  description = "Kubelet user-assigned identity principal ID."
  value       = azurerm_user_assigned_identity.kubelet.principal_id
}

output "system_node_pool_name" {
  description = "System node pool name."
  value       = local.system_node_pool_name
}

output "system_node_vm_size" {
  description = "System node pool VM size."
  value       = var.system_node_vm_size
}

output "system_subnet_id" {
  description = "System node subnet ID."
  value       = var.system_subnet_id
}

output "user_subnet_id" {
  description = "Reserved user node subnet ID for a later phase."
  value       = var.user_subnet_id
}


resource "azurerm_role_assignment" "control_plane_system_subnet_network_contributor" {
  scope                = var.system_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "control_plane_user_subnet_network_contributor" {
  scope                = var.user_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "control_plane_kubelet_identity_operator" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "current_principal_aks_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.platform.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = var.current_principal_type
}


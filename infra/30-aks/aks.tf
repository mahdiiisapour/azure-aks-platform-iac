resource "azurerm_kubernetes_cluster" "platform" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.dns_prefix
  sku_tier            = "Free"

  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                         = local.system_node_pool_name
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    os_disk_size_gb              = var.node_os_disk_size_gb
    os_disk_type                 = "Managed"
    os_sku                       = "AzureLinux"
    vnet_subnet_id               = var.system_subnet_id
    max_pods                     = var.max_pods
    only_critical_addons_enabled = true

    upgrade_settings {
      max_surge = var.system_node_max_surge
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.control_plane.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    ip_versions         = ["IPv4"]
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  tags = local.tags

  depends_on = [
    azurerm_role_assignment.control_plane_system_subnet_network_contributor,
    azurerm_role_assignment.control_plane_user_subnet_network_contributor,
    azurerm_role_assignment.control_plane_kubelet_identity_operator
  ]
}

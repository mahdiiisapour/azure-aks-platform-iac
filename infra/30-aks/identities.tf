resource "azurerm_user_assigned_identity" "control_plane" {
  name                = local.control_plane_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "kubelet" {
  name                = local.kubelet_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}


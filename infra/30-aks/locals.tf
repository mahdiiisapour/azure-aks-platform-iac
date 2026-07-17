locals {
  dns_prefix                  = var.cluster_name
  control_plane_identity_name = "id-aks-control-plane-${var.environment}-${var.region_short_code}"
  kubelet_identity_name       = "id-aks-kubelet-${var.environment}-${var.region_short_code}"
  system_node_pool_name       = "system"

  tags = {
    project             = "azure-aks-platform"
    environment         = var.environment
    managed-by          = "terraform"
    lifecycle           = "ephemeral"
    component           = "aks"
    owner               = "madi"
    cost-owner          = "personal-lab"
    data-classification = "internal"
  }
}


locals {
  location            = "northeurope"
  resource_group_name = "rg-aks-platform-dev-neu"

  common_tags = {
    project             = "azure-aks-platform"
    environment         = "dev"
    managed-by          = "terraform"
    lifecycle           = "persistent"
    component           = "foundation"
    owner               = "madi"
    cost-owner          = "personal-lab"
    data-classification = "internal"
  }
}


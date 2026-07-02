locals {
  storage_account_name             = "staksplatftf${random_string.storage_suffix.result}"
  platform_location                = "northeurope"
  platform_dev_resource_group_name = "rg-aks-platform-dev-neu"

  tags = {
    project             = "azure-aks-platform"
    environment         = "shared"
    managed-by          = "terraform"
    purpose             = "terraform-state"
    data-classification = "confidential"
  }

  platform_dev_tags = {
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

locals {
  storage_account_name = "staksplatftf${random_string.storage_suffix.result}"

  tags = {
    project             = "azure-aks-platform"
    environment         = "shared"
    managed-by          = "terraform"
    purpose             = "terraform-state"
    data-classification = "confidential"
  }
}


variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider. Prefer ARM_SUBSCRIPTION_ID for local use instead of a real tfvars file."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for bootstrap resources."
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Name of the bootstrap resource group."
  type        = string
  default     = "rg-aks-platform-bootstrap-neu"
}

variable "tfstate_container_name" {
  description = "Name of the blob container that will hold Terraform state."
  type        = string
  default     = "tfstate"
}

variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider. Prefer ARM_SUBSCRIPTION_ID for local use instead of a real tfvars file."
  type        = string
  default     = null
}


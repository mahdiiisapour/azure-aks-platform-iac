variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider. Prefer ARM_SUBSCRIPTION_ID for local use instead of a real tfvars file."
  type        = string
  default     = null
}

variable "environment" {
  description = "Platform environment name."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for AKS resources."
  type        = string
  default     = "northeurope"
}

variable "region_short_code" {
  description = "Short region code used in resource names."
  type        = string
  default     = "neu"
}

variable "resource_group_name" {
  description = "Persistent platform resource group that already exists."
  type        = string
  default     = "rg-aks-platform-dev-neu"
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "aks-platform-dev-neu"
}

variable "system_node_vm_size" {
  description = "VM size for the temporary one-node system pool."
  type        = string
  default     = "Standard_EC2as_v5"
}

variable "system_node_count" {
  description = "Fixed system node count for the Free Trial lab cluster."
  type        = number
  default     = 1

  validation {
    condition     = var.system_node_count == 1
    error_message = "This temporary Free Trial design intentionally uses exactly one system node."
  }
}

variable "system_node_max_surge" {
  description = "Maximum surge for system node pool upgrades."
  type        = string
  default     = "1"
}

variable "max_pods" {
  description = "Maximum pods per node for Azure CNI Overlay."
  type        = number
  default     = 30
}

variable "node_os_disk_size_gb" {
  description = "Managed OS disk size for AKS nodes."
  type        = number
  default     = 64
}

variable "pod_cidr" {
  description = "AKS pod CIDR for Azure CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "AKS service CIDR."
  type        = string
  default     = "10.245.0.0/16"
}

variable "dns_service_ip" {
  description = "AKS DNS service IP."
  type        = string
  default     = "10.245.0.10"
}

variable "vnet_address_space" {
  description = "Existing VNet address space from the network layer."
  type        = list(string)
}

variable "system_subnet_id" {
  description = "Existing system node subnet ID from the network layer."
  type        = string
}

variable "user_subnet_id" {
  description = "Existing user node subnet ID from the network layer. Reserved for a later user node pool phase."
  type        = string
}

variable "current_principal_type" {
  description = "Principal type for the signed-in human admin principal."
  type        = string
  default     = "User"
}

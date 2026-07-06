locals {
  location            = "northeurope"
  resource_group_name = "rg-aks-platform-dev-neu"

  vnet_name          = "vnet-aks-platform-dev-neu"
  vnet_address_space = ["10.50.0.0/16"]

  subnets = {
    aks_system = {
      name             = "snet-aks-system-dev-neu"
      address_prefixes = ["10.50.0.0/24"]
    }
    aks_user = {
      name             = "snet-aks-user-dev-neu"
      address_prefixes = ["10.50.1.0/24"]
    }
    private_endpoints = {
      name             = "snet-private-endpoints-dev-neu"
      address_prefixes = ["10.50.2.0/24"]
    }
    reserved = {
      name             = "snet-reserved-dev-neu"
      address_prefixes = ["10.50.3.0/24"]
    }
  }

  kubernetes_network = {
    pod_cidr       = "10.244.0.0/16"
    service_cidr   = "10.245.0.0/16"
    dns_service_ip = "10.245.0.10"
  }

  tags = {
    project             = "azure-aks-platform"
    environment         = "dev"
    managed-by          = "terraform"
    lifecycle           = "ephemeral"
    component           = "network"
    owner               = "madi"
    cost-owner          = "personal-lab"
    data-classification = "internal"
  }
}


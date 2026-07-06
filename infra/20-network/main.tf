resource "azurerm_virtual_network" "platform" {
  name                = local.vnet_name
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = local.vnet_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "platform" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes     = each.value.address_prefixes
}


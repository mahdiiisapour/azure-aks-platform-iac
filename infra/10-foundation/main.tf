resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.common_tags
}


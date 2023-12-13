#VNET Creation Module

resource "azurerm_resource_group" "rg" {
  name     = "${var.gcc}-${var.environment}-${local.short_location}-${var.service_name}-01-rg"
  location = "${var.location}"

  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.gcc}-${var.environment}-${local.short_location}-${var.service_name}-01-vn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  tags                = var.tags
}

resource "azurerm_subnet" "sub" {
  count                = length(var.subnet_address)

  name                 = "${var.service_name}-${count.index}-sub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet_address[count.index].address_prefix

  lifecycle {
    # TODO Remove this when azurerm 2.0 provider is released
    ignore_changes = [
      "route_table_id",
      "network_security_group_id",
    ]
  }
}

resource "azurerm_network_security_group" "vnet_nsg" {
  count               = length(var.subnet_address)

  name                = "${var.service_name}-${count.index}-sub-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "vnet_nsg" {
  count                       = length(local.flatten_nsg_rules)

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vnet_nsg[local.flatten_nsg_rules[count.index].subnet].name
  priority                    = local.flatten_nsg_rules[count.index].priority

  name                                       = local.flatten_nsg_rules[count.index].rule.name
  direction                                  = local.flatten_nsg_rules[count.index].rule.direction
  access                                     = local.flatten_nsg_rules[count.index].rule.access
  protocol                                   = local.flatten_nsg_rules[count.index].rule.protocol
  description                                = local.flatten_nsg_rules[count.index].rule.description
  source_port_range                          = local.flatten_nsg_rules[count.index].rule.source_port_range
  source_port_ranges                         = local.flatten_nsg_rules[count.index].rule.source_port_ranges
  destination_port_range                     = local.flatten_nsg_rules[count.index].rule.destination_port_range
  destination_port_ranges                    = local.flatten_nsg_rules[count.index].rule.destination_port_ranges
  source_address_prefix                      = local.flatten_nsg_rules[count.index].rule.source_address_prefix
  source_address_prefixes                    = local.flatten_nsg_rules[count.index].rule.source_address_prefixes
  source_application_security_group_ids      = local.flatten_nsg_rules[count.index].rule.source_application_security_group_ids
  destination_address_prefix                 = local.flatten_nsg_rules[count.index].rule.destination_address_prefix
  destination_address_prefixes               = local.flatten_nsg_rules[count.index].rule.destination_address_prefixes
  destination_application_security_group_ids = local.flatten_nsg_rules[count.index].rule.destination_application_security_group_ids
}

resource "azurerm_subnet_network_security_group_association" "vnet_nsg" {
  count                     = length(var.subnet_address)
  subnet_id                 = azurerm_subnet.sub[count.index].id
  network_security_group_id = azurerm_network_security_group.vnet_nsg[count.index].id
}

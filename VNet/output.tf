#Outputs for this module

output "vnet_name" {
  value = "${azurerm_virtual_network.vnet.name}"
}

output "vnet_address_space" {
  value = "${azurerm_virtual_network.vnet.address_space}"
}

output "vnet_location" {
  value = "${azurerm_virtual_network.vnet.location}"
}

output "vnet_id" {
  value = "${azurerm_virtual_network.vnet.id}"
}

output "subnet_id" {
  value = ["${azurerm_subnet.sub.*.id}"]
}

output "subnet_name" {
  value = ["${azurerm_subnet.sub.*.name}"]
}

output "subnet_address_prefix" {
  value = ["${azurerm_subnet.sub.*.address_prefix}"]
}

output "resource_group_name"{
  value = "${azurerm_resource_group.rg.name}"
}

output "resource_group_id"{
  value = "${azurerm_resource_group.rg.id}"
}

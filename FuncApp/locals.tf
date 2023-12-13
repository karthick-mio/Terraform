# LOCALS

####################################
### PLACE YOUR LOCAL VALUES HERE ###
####################################

locals {

  pe_properties_map = { for pe in var.storage_account_private_endpoint_properties : "${pe.private_endpoint_subresource}-${join("-", [split("/", pe.subnet_id)[8], split("/", pe.subnet_id)[10]])}" => pe }

}

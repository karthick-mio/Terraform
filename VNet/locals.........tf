locals {
  short_location    = lookup(var.short_locations, var.location, "weu")

  default_nsg_rule = {
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    description                                = null
    source_port_range                          = null
    source_port_ranges                         = null
    destination_port_range                     = null
    destination_port_ranges                    = null
    source_address_prefix                      = null
    source_address_prefixes                    = null
    source_application_security_group_ids      = null
    destination_address_prefix                 = null
    destination_address_prefixes               = null
    destination_application_security_group_ids = null
  }

  flatten_nsg_rules = flatten([for idx, subnet in var.subnet_address :
    [for ridx, r in subnet.security_rules : {
      subnet   = idx
      priority = 100 + 100 * ridx
      rule     = merge(local.default_nsg_rule, r)
    }]
  ])  
}

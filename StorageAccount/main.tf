# MODULE - Create Storage Account

#Naming for Storage Account

module "naming_convention_st" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_storage_account.location
  service_name    = var.service_name
  resource_type   = "Storage Account"
  instance_number = var.instance_number

}

resource "azurerm_storage_account" "st" {
  name                        = "${module.naming_convention_st.resource_name_no_hyphen}"
  location                    = var.resource_group_storage_account.location
  resource_group_name         = var.resource_group_storage_account.name
  account_tier                = "Standard"
  account_kind                = var.storage_kind
  account_replication_type    = var.storage_replication_type
  access_tier                 = var.storage_access_tier
  enable_https_traffic_only   = true

  tags = var.tags

}


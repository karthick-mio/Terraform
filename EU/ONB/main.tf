provider "azurerm" {
  version = "2.57.0"
  features {}
}

terraform {
  backend "azurerm" {}
}

locals {
  settings = jsondecode(file("${var.landscape}/${var.environment}/settings.json"))
}

module "mssql_databases" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/tf-az-modules//modules/databases/mssql_database?ref=legacy"


  for_each = local.settings.service[var.service]

  suffix = concat(var.suffix, [each.key])
  tags   = var.tags

  collation                   = try(each.value.collation, var.collation)
  read_scale                  = try(each.value.read_scale, var.read_scale)
  sku_name                    = try(each.value.sku_name, var.sku_name)
  max_size_gb                 = try(each.value.max_size_gb, var.max_size_gb)
  zone_redundant              = try(each.value.zone_redundant, var.zone_redundant)
  short_term_retention_policy = try(each.value.short_term_retention_policy, var.short_term_retention_policy)

  sql_server_id   = data.azurerm_mssql_server.service[each.key].id
  elastic_pool_id = data.azurerm_mssql_elasticpool.service[each.key].id
}

resource "azurerm_storage_container" "container" {
  for_each = var.exchange_db_name == null ? {} : local.settings.service[var.service]

  name                  = each.key
  storage_account_name  = data.azurerm_storage_account.st[0].name
  container_access_type = "private"
}



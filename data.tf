
data "azurerm_storage_account" "st" {
  count               = var.exchange_db_name != null ? 1 : 0
  name                = var.exchange_db_name
  resource_group_name = var.exchange_db_rg
}

# if there are database-specific attributes, use those
# if not then use the common values

data "azurerm_mssql_server" "service" {
  for_each = { for inst, cfg in local.settings.service[var.service] :
    inst => {
      server = try(cfg.mssql_server_name, var.mssql_server_name)
    }
  }

  name                = each.value.server
  resource_group_name = var.resource_group
}

data "azurerm_mssql_elasticpool" "service" {
  for_each = { for inst, cfg in local.settings.service[var.service] :
    inst => {
      server = try(cfg.mssql_server_name, var.mssql_server_name)
      pool   = try(cfg.mssql_elasticpool_name, var.mssql_elasticpool_name)
    }
  }

  resource_group_name = var.resource_group
  server_name         = each.value.server
  name                = each.value.pool
}


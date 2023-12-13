# MODULE - Web App

# Define App Service Plan

module "naming_convention_asp" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_webapp.location
  service_name    = var.service_name
  resource_type   = "App Service Plan"
  instance_number = var.instance_number

}

resource "azurerm_app_service_plan" "asp" {
  name                = module.naming_convention_asp.resource_name
  location            = var.resource_group_webapp.location
  resource_group_name = var.resource_group_webapp.name
  kind                = "App"

  sku {
    tier = var.web_app_tier
    size = var.web_app_size
  }

  tags = var.tags
}

# Define App Insight

module "naming_convention_ain" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_webapp.location
  service_name    = var.service_name
  resource_type   = "Application Insight"
  instance_number = var.instance_number

}

resource "azurerm_application_insights" "ain" {
  name                = module.naming_convention_ain.resource_name
  location            = var.resource_group_webapp.location
  resource_group_name = var.resource_group_webapp.name
  application_type    = "web"
  retention_in_days   = var.app_insight_retention_days
  sampling_percentage = var.app_insight_sampling_percentage

  tags = var.tags

}

# Define Web App

module "naming_convention_webapp" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_webapp.location
  service_name    = var.service_name
  resource_type   = "Web App"
  instance_number = var.instance_number

}


#Create storage account and container if storage URL was not provided (create it)

module "naming_convention_st" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_webapp.location
  service_name    = var.service_name
  resource_type   = "Storage Account"
  instance_number = var.instance_number

}

resource "azurerm_storage_account" "web_app_backup_st" {
  count                       = (var.enable_backup == true && var.backup_storage_url == "" ? 1 : 0)

  name                        = module.naming_convention_st.resource_name_no_hyphen
  location                    = var.resource_group_webapp.location
  resource_group_name         = var.resource_group_webapp.name
  account_tier                = "Standard"
  account_kind                = var.backup_storage_kind
  account_replication_type    = var.backup_storage_replication_type
  access_tier                 = var.backup_storage_access_tier
  enable_https_traffic_only   = true

  tags = var.tags

}

resource "azurerm_storage_container" "web_app_backup_cont" {
  count                 = (var.enable_backup == true && var.backup_storage_url == "" ? 1 : 0)
  name                  = var.backup_container_name
  storage_account_name  = azurerm_storage_account.web_app_backup_st[0].name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "web_app_backup_st_sas_2" {
  count             = (var.enable_backup == true && var.backup_storage_url == "" ? 1 : 0)
  connection_string = azurerm_storage_account.web_app_backup_st[0].primary_connection_string
  container_name    = azurerm_storage_container.web_app_backup_cont[0].name
  https_only        = true
  start             = "2020-01-03T17:18:00Z"
  expiry            = "2030-12-31T23:59:59Z"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}


#Create SAS token for storage account if backup is enabled. Storage account already exists.

data "azurerm_storage_account" "web_app_backup_storage" {
  count               = (var.enable_backup == true && var.backup_storage_url != "" ? 1 : 0)
  name                = split(".", split("/", var.backup_storage_url)[2])[0]
  resource_group_name = var.resource_group_webapp.name
}

data "azurerm_storage_container" "web_app_backup_container" {
  count                = (var.enable_backup == true && var.backup_storage_url != "" ? 1 : 0)
  name                 = var.backup_container_name
  storage_account_name = data.azurerm_storage_account.web_app_backup_storage[0].name
}


data "azurerm_storage_account_blob_container_sas" "web_app_backup_st_sas" {
  count             = (var.enable_backup == true && var.backup_storage_url != "" ? 1 : 0)
  connection_string = data.azurerm_storage_account.web_app_backup_storage[0].primary_connection_string
  container_name    = data.azurerm_storage_container.web_app_backup_container[0].name
  https_only        = true
  start             = "2020-01-03T17:18:00Z"
  expiry            = "2030-12-31T23:59:59Z"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

resource "azurerm_app_service" "web_app" {
  name                = module.naming_convention_webapp.resource_name
  location            = var.resource_group_webapp.location
  resource_group_name = var.resource_group_webapp.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  https_only          = true

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.ain.instrumentation_key
  }

  site_config {
    dotnet_framework_version = var.web_site_config_dotnet_version
    linux_fx_version         = var.web_site_config_dotnet_core_version
    scm_type                 = var.web_site_config_scm_type
    always_on                = var.always_on
  }

  dynamic "backup" {
    for_each = (var.enable_backup == true && var.backup_storage_url == "" ? [1] : [])

    content {
      name                = "${module.naming_convention_webapp.resource_name}_backup"
      enabled             = var.enable_backup
      storage_account_url = "https://${azurerm_storage_account.web_app_backup_st[0].name}.blob.core.windows.net/${azurerm_storage_container.web_app_backup_cont[0].name}${data.azurerm_storage_account_blob_container_sas.web_app_backup_st_sas_2[0].sas}"

      schedule {
        frequency_interval       = var.backup_frequency_interval
        frequency_unit           = var.backup_frequency_unit
        retention_period_in_days = var.backup_retention_days
        keep_at_least_one_backup = true
      }
    }
  }

  dynamic "backup" {
    for_each = (var.enable_backup == true && var.backup_storage_url != "" ? [1] : [])

    content {
      name                = "${module.naming_convention_webapp.resource_name}_backup"
      enabled             = var.enable_backup
      storage_account_url = "https://${data.azurerm_storage_account.web_app_backup_storage[0].name}.blob.core.windows.net/${data.azurerm_storage_container.web_app_backup_container[0].name}${data.azurerm_storage_account_blob_container_sas.web_app_backup_st_sas[0].sas}"

      schedule {
        frequency_interval       = var.backup_frequency_interval
        frequency_unit           = var.backup_frequency_unit
        retention_period_in_days = var.backup_retention_days
        keep_at_least_one_backup = true
      }
    }
  }

  lifecycle {
    ignore_changes = [app_settings, site_config]
  }

  tags = var.tags

}

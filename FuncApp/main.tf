# MODULE - Create Function App

#Define Storage Account

module "naming_convention_st" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_funapp.location
  service_name    = var.service_name
  resource_type   = "Storage Account"
  instance_number = var.instance_number

}

module "naming" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/terraform-azurerm-naming?ref=v1.0.1"
  suffix = [var.gcc, substr(var.environment, 0, 1), module.naming_convention_st.short_location, var.service_name, var.instance_number]
}

resource "azurerm_storage_account" "st" {
  name                      = var.new_naming ? module.naming.storage_account.name : module.naming_convention_st.resource_name_no_hyphen
  resource_group_name       = var.resource_group_funapp.name
  location                  = var.resource_group_funapp.location
  account_tier              = "Standard"
  account_kind              = var.storage_kind
  account_replication_type  = var.storage_replication_type
  enable_https_traffic_only = true
  min_tls_version           = var.storage_min_tls_version
  allow_blob_public_access  = var.storage_allow_blob_public_access

  blob_properties {
    delete_retention_policy {
      days = var.storage_blob_delete_retention_policy_days
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  dynamic "network_rules" {
    for_each = var.storage_account_network_rules == null ? [] : list(var.storage_account_network_rules)

    content {
      bypass                     = network_rules.value.bypass
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic "network_rules" {
    for_each = var.storage_account_network_rules == null ? [1] : []

    content {
      bypass         = ["AzureServices"]
      default_action = "Deny"
    }
  }

  tags = var.tags
}

# Lifecycle management rules

module "lifecycle_management_rules" {
  source = "./management_policy"
  count  = var.management_policy_rules != null ? 1 : 0

  storage_account_id = azurerm_storage_account.st.id
  rules              = var.management_policy_rules

}

# Private endpoint if subnet_id is set

resource "random_id" "private_endpoints" {
  for_each    = local.pe_properties_map
  byte_length = 5
}


resource "azurerm_private_endpoint" "st_pe" {
  for_each = local.pe_properties_map

  name = "pe-${each.value.private_endpoint_subresource}-${azurerm_storage_account.st.name}-${random_id.private_endpoints[each.key].hex}"

  resource_group_name = var.resource_group_funapp.name
  location            = var.resource_group_funapp.location

  subnet_id = each.value.subnet_id

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_id) != 0 ? [1] : []

    content {
      name                 = module.naming.private_dns_zone_group.name
      private_dns_zone_ids = each.value.private_dns_zone_id
    }

  }

  private_service_connection {
    name                           = "psc-${each.value.private_endpoint_subresource}-${azurerm_storage_account.st.name}-${random_id.private_endpoints[each.key].hex}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = [each.value.private_endpoint_subresource]
  }

  tags = var.tags
}

#Define App Service Plan

module "naming_convention_asp" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_funapp.location
  service_name    = var.service_name
  resource_type   = "App Service Plan"
  instance_number = var.instance_number

}

resource "azurerm_app_service_plan" "asp" {
  name                = var.new_naming ? "asp-${var.gcc}-${substr(var.environment, 0, 1)}-${module.naming_convention_st.short_location}-${var.service_name}-${var.instance_number}" : module.naming_convention_asp.resource_name
  location            = var.resource_group_funapp.location
  resource_group_name = var.resource_group_funapp.name
  kind                = "FunctionApp"

  sku {
    tier = var.function_app_tier
    size = var.function_app_size
  }

  tags = var.tags
}

#Define App Insight

module "naming_convention_ain" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_funapp.location
  service_name    = var.service_name
  resource_type   = "Application Insight"
  instance_number = var.instance_number

}

resource "azurerm_application_insights" "ain" {
  name                = var.new_naming ? "ain-${var.gcc}-${substr(var.environment, 0, 1)}-${module.naming_convention_st.short_location}-${var.service_name}-${var.instance_number}" : module.naming_convention_ain.resource_name
  location            = var.resource_group_funapp.location
  resource_group_name = var.resource_group_funapp.name
  application_type    = "web"

  retention_in_days = 90

  tags = var.tags
}

#Define Function App

module "naming_convention_fun" {
  source = "git::ssh://ProdNGAHR@vs-ssh.visualstudio.com/v3/ProdNGAHR/GT%20Cloud/module-naming-convention"

  gcc             = var.gcc
  environment     = var.environment
  location        = var.resource_group_funapp.location
  service_name    = var.service_name
  resource_type   = "Function App"
  instance_number = var.instance_number

}

resource "azurerm_function_app" "fun" {
  name                      = var.new_naming ? "fun-${var.gcc}-${substr(var.environment, 0, 1)}-${module.naming_convention_st.short_location}-${var.service_name}-${var.instance_number}" : module.naming_convention_fun.resource_name
  location                  = var.resource_group_funapp.location
  resource_group_name       = var.resource_group_funapp.name
  app_service_plan_id       = azurerm_app_service_plan.asp.id
  storage_connection_string = azurerm_storage_account.st.primary_connection_string
  version                   = var.function_runtime_version
  https_only                = true

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.ain.instrumentation_key
    FUNCTIONS_WORKER_RUNTIME       = "dotnet"
    WEBSITE_NODE_DEFAULT_VERSION   = "10.14.1"
  }

  site_config {
    always_on = var.function_app_site_config_always_on
  }

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/8171
  lifecycle {
    ignore_changes = [
      app_settings,
      version,
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      site_config["dotnet_framework_version"],
      site_config["scm_type"],
    ]

  }

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "function_app_vnet_integration" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_function_app.fun.id
  subnet_id      = var.subnet_id
}





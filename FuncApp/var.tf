# MODULE - Create Function App Input Variables

variable "gcc" {
  description = "The global company code."
  type        = string
}

variable "environment" {
  description = "The environment."
  type        = string
}

variable "location" {
  description = "The location."
  type        = string
}

variable "service_name" {
  description = "The service name."
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "instance_number" {
  description = "Instance number of resource to be created"
  type        = string
}

variable "resource_group_funapp" {
  description = "Resource Group (Object)"
  type        = object({ name = string, location = string })
}

variable "function_app_tier" {
  description = "Tier used in Azure Function Apps"
  type        = string
  default     = "Dynamic"
}

variable "function_app_size" {
  description = "Size used in Azure Web Apps"
  type        = string
  default     = "Y1"
}

variable "function_app_site_config_always_on" {
  description = "Enable to get the function loaded at all times"
  type        = bool
  default     = false
}

variable "storage_kind" {
  description = "Storage kind - valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2 "
  type        = string
  default     = "StorageV2"
}

variable "storage_replication_type" {
  description = "Storage replication type - valid options are LRS, GRS, RAGRS and ZRS "
  type        = string
  default     = "LRS"
}

variable "storage_blob_delete_retention_policy_days" {
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days"
  type        = number
  default     = 7
}

variable "storage_min_tls_version" {
  description = "Set the minimum supported TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "storage_allow_blob_public_access" {
  description = "Allow blob public access"
  type        = bool
  default     = true
}

variable "function_runtime_version" {
  description = "Function App Versions - valid options are ~1, ~2 and ~3"
  type        = string
  default     = "~2"
}

variable "new_naming" {
  type    = bool
  default = false
}

# Note: Web App VNEt Integration to be able to access private resource from Web App
# https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet

variable "subnet_id" {
  description = "The subnet id for VNET integration"
  type        = string
  default     = null
}

variable "storage_account_network_rules" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. See https://www.terraform.io/docs/providers/azurerm/r/storage_account.html#network_rules for more information"

  type = object({
    bypass                     = list(string),
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
  default = null
}

variable "storage_account_private_endpoint_properties" {
  description = "The private endpoint properties to add multiple endpoints if needed. Specify subnet, subresource and DNS zone"
  type = list(object({
    subnet_id                    = string
    private_dns_zone_id          = list(string)
    private_endpoint_subresource = string
  }))
  default = []
}

variable "management_policy_rules" {
  description = "Storage account lifecycle management policy rules"
  type        = any
  default     = null
}

variable "suffix" {
  type        = list(string)
  description = "naming suffix"
}

variable "environment" {
  type        = string
  description = "environment from where to read settings.json (DEV/TST/../PRD)"
}

variable "landscape" {
  type        = string
  description = "landscape from where to read settings.json (EU01/US01/.)"
}

variable "location" {
  type        = string
  description = "location for the storage accounts"
}

variable "service" {
  type        = string
  description = "indicates which data to lookup under settings.json"
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}

variable "resource_group" {
  type        = string
  description = "resource group where the mssql server sits"
}

variable "mssql_server_name" {
  type        = string
  description = "name of the mssql server"
}

variable "mssql_elasticpool_name" {
  type        = string
  description = "name of the elastic pool"
}

variable "sku_name" {
  type        = string
  description = "The SKU name for this MySQL server."
  default     = "BC_Gen5_2"
}

variable "collation" {
  type        = string
  description = "Collation of the DB server"
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "read_scale" {
  type        = bool
  description = "If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica"
  default     = true
}

variable "short_term_retention_policy" {
  description = "nested block: NestingList, min items: 0, max items: 1"
  type = list(object(
    {
      retention_days = number
    }
  ))
  default = []
}

variable "zone_redundant" {
  description = "(Optional) Specifies where the database should be zone redundant."
  default     = false
}

variable "max_size_gb" {
  description = "(optional)"
  type        = number
  default     = null
}

variable "account_kind" {
  description = "Storage kind - valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2 "
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage replication type - valid options are LRS, GRS, RAGRS and ZRS "
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Storage replication access tier - valid options are Hot and Cool"
  type        = string
  default     = "Hot"
}

variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Set the minimum supported TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "allow_blob_public_access" {
  description = "Allow or disallow public access to all blobs or containers in the storage account"
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2"
  type        = bool
  default     = false
}

variable "blob_delete_retention_policy_days" {
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days"
  type        = number
  default     = 7
}

variable "custom_domain_name" {
  description = "The Custom Domain Name to use for the Storage Account, which will be validated by Azure"
  type        = string
  default     = ""
}

variable "custom_domain_use_subdomain" {
  description = "Should the Custom Domain Name be validated by using indirect CNAME validation?"
  type        = bool
  default     = false
}

variable "static_website_index_document" {
  description = "The webpage that Azure Storage serves for requests to the root of a website or any subfolder. For example, index.html. The value is case-sensitive"
  type        = string
  default     = ""
}

variable "static_website_error_404_document" {
  description = "The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file"
  type        = string
  default     = ""
}

variable "network_rules" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. See https://www.terraform.io/docs/providers/azurerm/r/storage_account.html#network_rules for more information"

  type = object({
    bypass                     = list(string),
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
  default = null
}

variable "private_endpoint_properties" {
  description = "The private endpoint properties to add multiple endpoints if needed. Specify subnet, subresource and DNS zone"
  type = list(object({
    subnet_id                    = string
    private_dns_zone_id          = list(string)
    private_endpoint_subresource = string
  }))
  default = []
}

variable "containers" {
  description = "List of container names"
  type        = list(string)
  default     = []
}

variable "container_delete_retention_policy_days" {
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days"
  type        = number
  default     = 7
}

variable "management_policy_rules" {
  description = "Storage account lifecycle management policy rules"
  type        = any
  default     = null
}

variable "cors_rule" {
  description = "enable a web application running under one domain to access resources in another domain"
  type        = map(any)
  default     = {}
}

variable "exchange_db_name" {
  description = "name of the exchange database"
  type        = string
  default     = null
}

variable "exchange_db_rg" {
  description = "resource group where the exchange database is located"
  type        = string
  default     = null
}

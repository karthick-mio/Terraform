# Input variables

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

variable "short_locations" {
  description = "The list of short location names."
  type        = "map"
  default = {
    "North Europe" = "neu"
    "West Europe"  = "weu"
  }
}

variable "service_name" {
  description = "The service name."
  type        = string
}

variable "tags" {
  type        = "map"
}

variable "address_space" {
  description = "Address space for Spoke VNET"
  type        = list
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = "list"
  default     = []
}

variable "subnet_address" {
  description = "Address and NSG for subnet"
  type        =  list(object({address_prefix = string, security_rules = list(any)}))
}

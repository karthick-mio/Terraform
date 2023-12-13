# MODULE - Create Storage Account Input Variables

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
  type = "map"
}

variable "instance_number" {
  description = "Instance number of resource to be created"
  type        = string
}

variable "resource_group_storage_account" {
  description = "Resource Group (Object)"
  type        = object({ name = string, location = string })
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

variable "storage_access_tier" {
  description = "Storage replication access tier - valid options are Hot and Cool"
  type        = string
  default     = "Hot"
}

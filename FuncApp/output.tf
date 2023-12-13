#Outputs for this module

output "funapp_storage_account_id" {
  value = azurerm_storage_account.st.id
}

output "funapp_storage_account_blobendpoint" {
  value = azurerm_storage_account.st.primary_blob_endpoint
}

output "funapp_storage_account_primary_connection_string" {
  value = azurerm_storage_account.st.primary_connection_string
}

output "funapp_storage_account_secondary_connection_string" {
  value = azurerm_storage_account.st.secondary_connection_string
}

output "management_policy_id" {
  description = "The ID of the Storage Account Management Policy."
  value       = module.lifecycle_management_rules.*.management_policy_id
}

resource "azurerm_key_vault_access_policy" "kvpolicy" {
  key_vault_id = var.keyvaultid
  tenant_id = var.tenant_id
  object_id = var.object_id
  key_permissions = var.keypermissionspolicy
  secret_permissions = var.secretpremissionspolicy
}
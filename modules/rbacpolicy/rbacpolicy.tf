# role of Key Vault Secrets User is Azure Built-In role
resource "azurerm_role_assignment" "azrbacpolicy" {
  scope = var.keyvaultid
  role_definition_name = "Key Vault Secrets User"
  principal_id = var.object_id
}
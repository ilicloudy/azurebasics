#resource key vault secret
# 1. key
# 2. secret
# 3. key vault id 
resource "azurerm_key_vault_secret" "azkey" {
  name         = var.key
  value        = var.secret
  key_vault_id = var.keyvaultid

}
#output is the key vault id which is going to be used by the other modules 
#of key vault Policy and key vault secret
output "keyvaultid" {
    value = azurerm_key_vault.azkeyvault.id
}
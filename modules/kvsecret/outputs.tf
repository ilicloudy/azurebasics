output "secretname" {
    value = azurerm_key_vault_secret.azkey.value
    sensitive = true
}
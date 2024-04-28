resource "azurerm_key_vault" "azkeyvault"{
  name = var.keyvaultname
  location = var.location
  resource_group_name = var.rgvault
  sku_name = "standard"
  tenant_id = var.tenant_id
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions = var.keypermissionspolicy
    secret_permissions = var.secretpremissionspolicy
  }
}










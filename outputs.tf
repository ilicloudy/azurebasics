#output azure bastion subnet name
output "az-bastionsubnet-name" {
  value = azurerm_subnet.azbastionsubnet.name
}
This code is creating the following resources:
a VNET with two subnets 
1. Server Subnet
2. Azure Bastion
Virtual Machine- Ubuntu provisioned in Server Subnet
Azure Key Vault where 2 secrets are created the username and pwd of Virtual Machine
Thus in the creation of VM username and pwd are going to be retrieved from Azure Key Vault.

- Example of Azure Key Vault Policy for an Azure Service Principal way of access to Azure Key Vault Secrets.
- NSG for Azure Bastion subnet is provisioned according to official documentation of Azure.
- Azure Key Vault components are implemented as modules in the code.
- Sensitive variables are set as environmental variables for security.
Tip: At prompt in windows you should set environmental variables 
    $env:TF_VAR_pwd="xxxxxxxxxxxxxxx"
    $env:TF_VAR_useradmin="xxxxxxxxxxxxx"
    terraform apply -var pwd=$env:TF_VAR_pwd -var username=$env:TF_VAR_username 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.100.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.48.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azkeyvaultpolicy"></a> [azkeyvaultpolicy](#module\_azkeyvaultpolicy) | ./modules/kvpolicy | n/a |
| <a name="module_azpassword"></a> [azpassword](#module\_azpassword) | ./modules/kvsecret | n/a |
| <a name="module_azuserkey"></a> [azuserkey](#module\_azuserkey) | ./modules/kvsecret | n/a |
| <a name="module_myazkeyvault"></a> [myazkeyvault](#module\_myazkeyvault) | ./modules/keyvault | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.azbastionhost](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_network_interface.servernic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.azb-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.bastionpublicip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rgazkeyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.rgbastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.azbastionsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.serverssubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.azbnsgassoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_machine.vm1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_network.hubvnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azuread_service_principal.myapp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addressspace"></a> [addressspace](#input\_addressspace) | Address Space for VNET | `list(any)` | <pre>[<br>  "192.168.0.0/25"<br>]</pre> | no |
| <a name="input_appname"></a> [appname](#input\_appname) | n/a | `any` | n/a | yes |
| <a name="input_azbastionsubnet"></a> [azbastionsubnet](#input\_azbastionsubnet) | Address Space for VNET | `list(any)` | <pre>[<br>  "192.168.0.0/26"<br>]</pre> | no |
| <a name="input_keyvaultname"></a> [keyvaultname](#input\_keyvaultname) | az key vault name | `string` | `"keyvaul"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location where the whole deployment is going to take place | `string` | `"westeurope"` | no |
| <a name="input_object_id"></a> [object\_id](#input\_object\_id) | id of object | `string` | n/a | yes |
| <a name="input_pwd"></a> [pwd](#input\_pwd) | pwd of vm | `string` | n/a | yes |
| <a name="input_rgname"></a> [rgname](#input\_rgname) | Resource group name for bastion | `string` | `"rg-azure-bastion"` | no |
| <a name="input_rgvault"></a> [rgvault](#input\_rgvault) | Resource group name of vault | `string` | `"rg-azkeyvault"` | no |
| <a name="input_serversubnet"></a> [serversubnet](#input\_serversubnet) | Address Space for VNET | `list(any)` | <pre>[<br>  "192.168.64.0/27"<br>]</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | id of tenant | `string` | n/a | yes |
| <a name="input_useradmin"></a> [useradmin](#input\_useradmin) | admin of vm | `string` | n/a | yes |
| <a name="input_vnetname"></a> [vnetname](#input\_vnetname) | vnet name | `string` | `"vnetbastion"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_az-bastionsubnet-name"></a> [az-bastionsubnet-name](#output\_az-bastionsubnet-name) | output azure bastion subnet name |
<!-- END_TF_DOCS -->
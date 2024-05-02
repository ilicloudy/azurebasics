#create resource group for hosting Azure Bastion
#requires two variables location and resource group name
resource "azurerm_resource_group" "rgbastion" {
  location = var.location
  name     = var.rgname
}

#create resource group for hosting Azure Key Vault
#requires two variables location and resource group name
resource "azurerm_resource_group" "rgazkeyvault" {
  location = var.location
  name     = var.rgvault
}

#create resource Azure Virtual Network
#requires 4 parameters 
#1. location = Azure region
#2. vnet name
#3. resource group name
#4. address space CIDR block
resource "azurerm_virtual_network" "hubvnet" {
  location            = azurerm_resource_group.rgbastion.location
  name                = var.vnetname
  resource_group_name = azurerm_resource_group.rgbastion.name
  address_space       = var.addressspace
}

#create resource Azure Subnet for Bastion
#requires 4 parameters 
#1. location = Azure region
#2. subnet name is predefined by Azure 
#3. resource group name
#4. address_prefixes CIDR block
resource "azurerm_subnet" "azbastionsubnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  resource_group_name  = azurerm_resource_group.rgbastion.name
  address_prefixes     = var.azbastionsubnet
}

#create resource Azure Subnet for Servers
#requires 4 parameters 
#1. location = Azure region
#2. subnet name
#3. resource group name
#4. address_prefixes CIDR block
resource "azurerm_subnet" "serverssubnet" {
  name                 = "ServersSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  resource_group_name  = azurerm_resource_group.rgbastion.name
  address_prefixes     = var.serversubnet
}

#create public ip that is needed for Azure Bastion
#requires 4 parameters 
#1. location = Azure region
#2. name of public ip
#3. resource group name
#4. allocation method Static
#5. sku Standard
resource "azurerm_public_ip" "bastionpublicip" {
  name                = "BastionIP"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#create Azure Bastion
#requires the following parameters 
#1. location = Azure region
#2. name of Azure Bastion
#3. resource group name
#4. sku Basic
#5. ip configuration=> public_ip and subnet_id
resource "azurerm_bastion_host" "azbastionhost" {
  name                = "AzBastion"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name
  sku                 = "Basic"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azbastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastionpublicip.id
  }

}


#create Azure Key Vault
#Key Vault Name should be globally unique
module "myazkeyvault" {
  source       = "./modules/keyvault"
  location     = var.location
  rgvault      = var.rgvault
  keyvaultname = var.keyvaultname
  tenant_id    = var.tenant_id
  object_id    = var.object_id
  
  #if RBAC Policy is used comment keypermissionspolicy block and secretpremissionspolicy block
  keypermissionspolicy = [
    "Create",
    "Get",
    "Delete",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
  secretpremissionspolicy = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover",
    "List"
  ]

}

#import app already created in Azure AD
data "azuread_service_principal" "myapp" {
  display_name = var.appname
}

#create Azure Key Vault Policy for app
module "azkeyvaultpolicy" {
  source               = "./modules/kvpolicy"
  keyvaultid           = module.myazkeyvault.keyvaultid
  tenant_id            = var.tenant_id
  object_id            = data.azuread_service_principal.myapp.object_id
  keypermissionspolicy = ["Get", "List", "Encrypt", "Decrypt"]
}

#if RBAC Policy used to access secrets stored in Azure Key Vault
#uncomment the following block of code 
 module "azrbacpolicy" {
   source               = "./modules/rbacpolicy"
   keyvaultid           = module.myazkeyvault.keyvaultid
   object_id = data.azuread_service_principal.myapp.object_id
}


#create Azure Key Vault Secret for username of VM-server to be created
module "azuserkey" {
  source     = "./modules/kvsecret"
  keyvaultid = module.myazkeyvault.keyvaultid
  key        = "username"
  secret     = var.useradmin
}
#create Azure Key Vault Secret for password of VM-server to be created
module "azpassword" {
  source     = "./modules/kvsecret"
  keyvaultid = module.myazkeyvault.keyvaultid
  key        = "password"
  secret     = var.pwd
}


#create Network Interface for VM-server in serversubnet with DynamicIP
resource "azurerm_network_interface" "servernic" {
  name                = "vmlinuxdream-nic"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name

  ip_configuration {
    name                          = "vmlinuxdream-conf"
    subnet_id                     = azurerm_subnet.serverssubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#create Virtual Machine Standard_B2ms with ubuntu os 
#1. delete os disk on termination
#2. username password retrieved from Azure Key Vault at run time
resource "azurerm_virtual_machine" "vm1" {
  name                  = "vmlinuxdream"
  location              = azurerm_resource_group.rgbastion.location
  resource_group_name   = azurerm_resource_group.rgbastion.name
  network_interface_ids = [azurerm_network_interface.servernic.id]
  vm_size               = "Standard_b2ms"


  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = module.azuserkey.secretname
    admin_password = module.azpassword.secretname
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

#create Azure Network Security Group
#for Azure Bastion
#the list of rules are defined in official documentation in Azure 
#https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg
resource "azurerm_network_security_group" "azb-nsg" {
  name                = "AzureBastionNSG"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name

  security_rule {
    name                       = "AllowInboundRDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5701"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowInboundRDP2"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "AllowInboundGM"
    priority                   = 170
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowInboundLB"
    priority                   = 180
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "AllowInboundHTTPS"
    priority                   = 190
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundRemoteSSH"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowOutboundBastionMGMT"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowOutboundBastionMGMT2"
    priority                   = 230
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5071"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowOutboundRemoteRDP"
    priority                   = 240
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "azbnsgassoc" {
  subnet_id                 = azurerm_subnet.azbastionsubnet.id
  network_security_group_id = azurerm_network_security_group.azb-nsg.id
}

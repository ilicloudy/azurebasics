resource "azurerm_resource_group" "rgbastion" {
  location = var.location
  name     = var.rgname
}

resource "azurerm_virtual_network" "hubvnet" {
  location            = azurerm_resource_group.rgbastion.location
  name                = var.vnetname
  resource_group_name = azurerm_resource_group.rgbastion.name
  address_space       = var.addressspace
}

resource "azurerm_subnet" "azbastionsubnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  # location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name
  address_prefixes    = var.azbastionsubnet
}

resource "azurerm_subnet" "serverssubnet" {
  name                 = "ServersSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  # location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name
  address_prefixes    = var.serversubnet
}

resource "azurerm_public_ip" "bastionpublicip" {
  name                = "BastionIP"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


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

resource "azurerm_network_interface" "servernic" {
  name                = "vmlinuxili-nic"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name

  ip_configuration {
    name                          = "vmlinuxili-conf"
    subnet_id                     = azurerm_subnet.serverssubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = "vmlinuxili"
  location              = azurerm_resource_group.rgbastion.location
  resource_group_name   = azurerm_resource_group.rgbastion.name
  network_interface_ids = [azurerm_network_interface.servernic.id]
  vm_size               = "Standard_b2ms"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

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
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_network_security_group" "azb-nsg" {
  name                = "AzureBastionNSG"
  location            = azurerm_resource_group.rgbastion.location
  resource_group_name = azurerm_resource_group.rgbastion.name

  security_rule {
    name                       = "AllowINboundRDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundHTTP"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "Production"
  }
}

/*resource "azurerm_subnet_network_security_group_association" "azbnsgassoc" {
  subnet_id                 = azurerm_subnet.azbastionsubnet.id
  network_security_group_id = azurerm_network_security_group.azb-nsg.id
}*/

# Create virtual machine
resource "azurerm_linux_virtual_machine" "speedy1" {
  name                  = "speedy1"
  location              = azurerm_resource_group.speedy.location
  resource_group_name   = azurerm_resource_group.speedy.name
  network_interface_ids = [azurerm_network_interface.speedy.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "speedy1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint
  }
}

/*
A Network interface (NIC) is the interconnection between a virtual machine and a virtual network.
A VM must have a least one NIC
https://docs.microsoft.com/en-us/azure/virtual-network/network-overview
*/
resource "azurerm_network_interface" "speedy" {
  name                = "speedy1-nic"
  location            = azurerm_resource_group.speedy.location
  resource_group_name = azurerm_resource_group.speedy.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.speedy.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.speedy.id
  }
}

# Create public IPs
resource "azurerm_public_ip" "speedy" {
  name                = "speedyPublicIP"
  location            = azurerm_resource_group.speedy.location
  resource_group_name = azurerm_resource_group.speedy.name
  allocation_method   = "Dynamic"
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "speedy" {
  network_interface_id      = azurerm_network_interface.speedy.id
  network_security_group_id = azurerm_network_security_group.speedy.id
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



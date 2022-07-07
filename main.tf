resource "azurerm_resource_group" "speedy" {
  name      = "rg.speedy"
  location  = "West Europe"
}

/* 
Creating a vm
A VM needs a virtual network.
A VM needs at least one NIC
*/
resource "azurerm_virtual_network" "speedy" {
  name                = "speedyVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.speedy.location
  resource_group_name = azurerm_resource_group.speedy.name
}
/*
A subnet is a range of IP addressed in the virtual network. 
Each NIC in a VM is connected to one subnet in one virtual network.
*/
resource "azurerm_subnet" "speedy" {
  name                 = "speedySubnet1"
  resource_group_name  = azurerm_resource_group.speedy.name
  virtual_network_name = azurerm_virtual_network.speedy.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "speedy" {
  name                = "speedyPublicIP"
  location            = azurerm_resource_group.speedy.location
  resource_group_name = azurerm_resource_group.speedy.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "speedy" {
  name                = "speedyNetworkSecurityGroup"
  location            = azurerm_resource_group.speedy.location
  resource_group_name = azurerm_resource_group.speedy.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

/*
A Network interface (NIC) is the interconnection between a virtual machine and a virtual network.
A VM must have a least one NIC
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

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.speedy.id
  network_security_group_id = azurerm_network_security_group.speedy.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.speedy.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "test" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.speedy.location
  resource_group_name      = azurerm_resource_group.speedy.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

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
    storage_account_uri = azurerm_storage_account.test.primary_blob_endpoint
  }
}


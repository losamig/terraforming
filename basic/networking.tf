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
resource "azurerm_resource_group" "speedy" {
  name      = "rg.speedy"
  location  = "West Europe"
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
# An Azure storage account contains all of your Azure Storage data objects, including blobs, file shares, 
# queues, tables, and disks. The storage account provides a unique namespace for your Azure Storage data 
# that's accessible from anywhere in the world over HTTP or HTTPS. Data in your storage account is durable 
# and highly available, secure, and massively scalable.
# https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
resource "azurerm_storage_account" "diagnostics" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.speedy.location
  resource_group_name      = azurerm_resource_group.speedy.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}






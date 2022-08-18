# Creating an Azure Container Registry (ACR)
# https://docs.microsoft.com/en-us/azure/container-registry/

resource "azurerm_container_registry" "acr" {
  name                     = "acr"
  location                 = azurerm_resource_group.speedy.location
  resource_group_name      = azurerm_resource_group.speedy.name
  sku                      = "Basic"
  admin_enabled            = true
} 
terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.46.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstateg6eln" //comes from executing create-remote-storage
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }  
}

provider "azurerm" {
  features {}
}
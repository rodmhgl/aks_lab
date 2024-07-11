terraform {
  required_version = "1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.111.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

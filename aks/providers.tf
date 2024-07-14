terraform {
  required_version = "1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.111.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.31.0"
    # }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "2.14.0"
    # }
  }
}

provider "azuread" {}
provider "random" {}
provider "local" {}
provider "null" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# provider "kubernetes" {
#   config_path = local_file.kubeconfig.filename
# }

# provider "helm" {
#   # kubernetes {
#   #   config_path = local_file.kubeconfig.filename
#   # }
# }
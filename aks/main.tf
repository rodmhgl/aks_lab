module "naming_aks" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
  prefix  = ["akslab"]
}

resource "azurerm_resource_group" "aks" {
  name     = module.naming_aks.resource_group.name
  location = var.location
  tags     = local.tags
}

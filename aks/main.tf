module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
  prefix = ["akslab"]
}

resource "azurerm_resource_group" "aks" {
  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "aks" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = local.tags
}

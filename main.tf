moved {
  from = azurerm_resource_group.rg
  to   = azurerm_resource_group.aks
}

resource "azurerm_resource_group" "aks" {
  name     = "k8s-scaling-rg"
  location = "East US"
  tags = {
    "purpose" = "k8s scaling lab"
  }
}

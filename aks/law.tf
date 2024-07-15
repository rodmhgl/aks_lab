resource "azurerm_log_analytics_workspace" "this" {
  name                = module.naming_aks.log_analytics_workspace.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  retention_in_days   = 30
  identity {
    type = "SystemAssigned"
  }
}

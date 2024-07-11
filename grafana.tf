resource "azurerm_dashboard_grafana" "metrics" {
  name                = "amg-metrics"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.metrics.id
  }
}

# Let's give ourselves Grafana Admin permissions
resource "azurerm_role_assignment" "amg_me" {
  role_definition_name = "Grafana Admin"
  scope                = azurerm_dashboard_grafana.metrics.id
  principal_id         = data.azurerm_client_config.current.object_id
}

# And let's give Grafana permissions to read metrics
resource "azurerm_role_assignment" "amon_amg" {
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.metrics.identity[0].principal_id
  scope                = azurerm_monitor_workspace.metrics.id
}

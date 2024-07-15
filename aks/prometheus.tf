resource "azurerm_monitor_workspace" "metrics" {
  name                = "amon-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}

resource "azurerm_role_assignment" "metrics" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Monitoring Data Reader"
  scope                = azurerm_monitor_workspace.metrics.id
}

resource "azurerm_monitor_data_collection_endpoint" "metrics" {
  name                = "msprom--${azurerm_resource_group.aks.location}-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "metrics" {
  name                        = "msprom--${azurerm_resource_group.aks.location}-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name         = azurerm_resource_group.aks.name
  location                    = azurerm_resource_group.aks.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.metrics.id

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.metrics.id
      name               = azurerm_monitor_workspace.metrics.name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = [azurerm_monitor_workspace.metrics.name]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"

  depends_on = [
    azurerm_monitor_data_collection_endpoint.metrics
  ]
}

# associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "dcr_to_aks" {
  name                    = "dcr-${azurerm_kubernetes_cluster.aks.name}"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.metrics.id

  description = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."

  depends_on = [
    azurerm_monitor_data_collection_endpoint.metrics
  ]
}

# associate to a Data Collection Endpoint
resource "azurerm_monitor_data_collection_rule_association" "dce_to_aks" {
  target_resource_id          = azurerm_kubernetes_cluster.aks.id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.metrics.id
}

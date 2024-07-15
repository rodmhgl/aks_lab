#region For privatized clusters
# resource "azurerm_private_dns_zone" "aks" {
#   name                = "privatelink.eastus2.azmk8s.io"
#   resource_group_name = azurerm_resource_group.aks.name
# }

# resource "azurerm_role_assignment" "aks_dns" {
#   scope                = azurerm_private_dns_zone.aks.id
#   role_definition_name = "Private DNS Zone Contributor"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }
#endregion

#region AKS User-Assigned Identities
module "cluster-uai" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.1"

  name                = "cluster-${module.naming_aks.user_assigned_identity.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  enable_telemetry    = false
  tags                = azurerm_resource_group.aks.tags
}

module "kubelet-uai" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.1"

  name                = "kubelet-${module.naming_aks.user_assigned_identity.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  enable_telemetry    = false
  tags                = azurerm_resource_group.aks.tags
}
#endregion

# Required for AKS UAI to create kubelet identity
resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.cluster-uai.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  #TODO: This should be privatized, but who has the time?
  name                      = module.naming_aks.kubernetes_cluster.name
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  sku_tier                  = "Standard"
  azure_policy_enabled      = true
  cost_analysis_enabled     = false
  image_cleaner_enabled     = false
  dns_prefix                = "aks-${module.naming_aks.kubernetes_cluster.name}"
  automatic_channel_upgrade = "stable"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  tags                      = azurerm_resource_group.aks.tags

  # microsoft_defender {
  #   log_analytics_workspace_id = 
  # }

  # service_mesh_profile {
  #   mode                             = "Istio"
  #   external_ingress_gateway_enabled = true
  # }

  # network_profile {
  #   network_plugin = "azure"
  #   load_balancer_sku = "standard"
  # }

  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }

  default_node_pool {
    name                        = "systempool"
    vm_size                     = "Standard_B4s_v2"
    node_count                  = 3
    min_count                   = 1
    max_count                   = 4
    temporary_name_for_rotation = "bababooey"
    enable_auto_scaling         = true

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    managed            = true
    admin_group_object_ids = [
      data.azuread_group.aks_admins.id
    ]
    tenant_id = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.cluster-uai.resource.id
    ]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }

  kubelet_identity {
    client_id                 = module.kubelet-uai.resource.client_id
    object_id                 = module.kubelet-uai.principal_id
    user_assigned_identity_id = module.kubelet-uai.resource.id
  }

  depends_on = [
    azurerm_role_assignment.managed_identity_operator
  ]

  lifecycle {
    ignore_changes = [ default_node_pool[0].node_count ]
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "MSCI-${azurerm_resource_group.aks.location}-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams      = ["Microsoft-ContainerLog", "Microsoft-ContainerLogV2", "Microsoft-KubeEvents", "Microsoft-KubePodInventory", "Microsoft-KubeNodeInventory", "Microsoft-KubePVInventory", "Microsoft-KubeServices", "Microsoft-KubeMonAgentEvents", "Microsoft-InsightsMetrics", "Microsoft-ContainerInventory", "Microsoft-ContainerNodeInventory", "Microsoft-Perf"]
    destinations = ["ciworkspace"]
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    syslog {
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "cron", "daemon", "mark", "kern", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", "lpr", "mail", "news", "syslog", "user", "uucp"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "sysLogsDataSource"
    }

    extension {
      streams        = ["Microsoft-ContainerLog", "Microsoft-ContainerLogV2", "Microsoft-KubeEvents", "Microsoft-KubePodInventory", "Microsoft-KubeNodeInventory", "Microsoft-KubePVInventory", "Microsoft-KubeServices", "Microsoft-KubeMonAgentEvents", "Microsoft-InsightsMetrics", "Microsoft-ContainerInventory", "Microsoft-ContainerNodeInventory", "Microsoft-Perf"]
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        "dataCollectionSettings" : {
          "interval" : "1m",
          "namespaceFilteringMode" : "off",
          "namespaces" : ["kube-system", "gatekeeper-system", "azure-arc", "itops"]
          "enableContainerLogV2" : true
        }
      })
      name = "ContainerInsightsExtension"
    }
  }

  description = "DCR for Azure Monitor Container Insights"

}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association of container insights data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}

resource "local_file" "kubeconfig" {
  filename = "/Users/rodneystewart/.kube/config"
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
}

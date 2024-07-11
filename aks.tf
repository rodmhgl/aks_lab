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
resource "azurerm_user_assigned_identity" "aks" {
  name                = "k8s-scaling-aks-identity"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = azurerm_resource_group.aks.tags
}

resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "k8s-scaling-kubelet-identity"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = azurerm_resource_group.aks.tags
}
#endregion

# Required for AKS UAI to create kubelet identity
resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  #TODO: This should be privatized, but who has the time?
  name                      = "k8s-scaling-aks"
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  sku_tier                  = "Standard"
  azure_policy_enabled      = true
  cost_analysis_enabled     = false
  image_cleaner_enabled     = false
  dns_prefix                = "k8s-scaling-aks"
  automatic_channel_upgrade = "stable"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  tags                      = azurerm_resource_group.aks.tags

  monitor_metrics {}

  default_node_pool {
    name                        = "systempool"
    vm_size                     = "Standard_B4s_v2"
    node_count                  = 3
    temporary_name_for_rotation = "bababooey"

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
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  depends_on = [
    azurerm_role_assignment.managed_identity_operator
  ]
}

resource "local_file" "kubeconfig" {
  filename = "/Users/rodneystewart/.kube/config"
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
}
module "azure_container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.1.0"

  name                = "rn${module.naming.container_registry.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  admin_enabled                 = true
  anonymous_pull_enabled        = false
  enable_telemetry              = false
  public_network_access_enabled = true
  network_rule_bypass_option    = "AzureServices"
  tags                          = azurerm_resource_group.aks.tags
  managed_identities = {
    system_assigned = false
    user_assigned_resource_ids = [
      module.acr-uai.resource.id
    ]
  }
  role_assignments = {
    aks_pull = {
      role_definition_id_or_name       = "AcrPull"
      principal_id                     = module.cluster-uai.principal_id
      description                      = "Allow AKS to pull images from ACR"
      skip_service_principal_aad_check = false
    }
  }
}

output "uai-output" {
  value = module.acr-uai
}
module "acr-uai" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.1"

  name                = "acr-${module.naming.user_assigned_identity.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  enable_telemetry    = false
  tags                = azurerm_resource_group.aks.tags
}

# resource "azurerm_role_assignment" "aks_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }

#TODO: Are these both (kubelet_acr_pull and aks_acr_pull) needed?
# resource "azurerm_role_assignment" "kubelet_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
# }

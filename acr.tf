resource "azurerm_container_registry" "acr" {
  name                = "k8sscalingacr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = azurerm_resource_group.aks.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

#TODO: Are these both (kubelet_acr_pull and aks_acr_pull) needed?
# resource "azurerm_role_assignment" "kubelet_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
# }

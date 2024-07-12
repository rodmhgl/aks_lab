resource "azurerm_container_registry" "acr" {
  name                = "acr${local.name}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = azurerm_resource_group.aks.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.acr.id
    ]
  }

  # encryption = {
  #   enabled            = true
  #   key_vault_key_id   = data.azurerm_key_vault_key.example.id
  #   identity_client_id = azurerm_user_assigned_identity.acr.client_id
  # }
}

resource "azurerm_user_assigned_identity" "acr" {
  name                = "registry-uai"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
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

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azuread_group" "aks_admins" {
  display_name = "k8s_admins"
}
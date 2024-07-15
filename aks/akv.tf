# resource "azurerm_key_vault" "aks" {
#   #TODO: This should be privatized, but who has the time?
#   name                            = module.naming_aks.key_vault.name_unique
#   location                        = azurerm_resource_group.aks.location
#   resource_group_name             = azurerm_resource_group.aks.name
#   tenant_id                       = data.azurerm_client_config.current.tenant_id
#   sku_name                        = "standard"
#   soft_delete_retention_days      = 7
#   purge_protection_enabled        = false
#   enable_rbac_authorization       = true
#   enabled_for_deployment          = true
#   enabled_for_disk_encryption     = true
#   enabled_for_template_deployment = true
#   public_network_access_enabled   = true
#   tags                            = azurerm_resource_group.aks.tags
# }

# #TODO: Reduce these permisions to the minimum required
# resource "azurerm_role_assignment" "akv_admin" {
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = module.cluster-uai.principal_id
#   scope                = azurerm_key_vault.aks.id
# }
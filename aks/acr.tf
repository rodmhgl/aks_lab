module "azure_container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.1.0"

  name                = "rnlabacr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  admin_enabled                 = true
  anonymous_pull_enabled        = false
  enable_telemetry              = false
  public_network_access_enabled = true
  network_rule_bypass_option    = "AzureServices"
  tags                          = azurerm_resource_group.aks.tags

  # managed_identities = {
  #   system_assigned = false
  #   user_assigned_resource_ids = [
  #     module.acr_uai.resource.id
  #   ]
  # }

  role_assignments = {
    aks_pull = {
      role_definition_id_or_name       = "AcrPull"
      principal_id                     = module.cluster-uai.principal_id
      description                      = "Allow AKS to pull images from ACR"
      skip_service_principal_aad_check = false
    }
  }
}

module "acr_uai" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.1"

  name                = module.naming_aks.user_assigned_identity.name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  enable_telemetry    = false
  tags                = azurerm_resource_group.aks.tags
}

# module "cmk_keyvault" {
#   source  = "Azure/avm-res-keyvault-vault/azurerm"
#   version = "0.7.1"

#   name                          = module.naming_acr.key_vault.name_unique
#   location                      = azurerm_resource_group.acr.location
#   resource_group_name           = azurerm_resource_group.acr.name
#   tenant_id                     = data.azurerm_client_config.current.tenant_id
#   enable_telemetry              = false
#   public_network_access_enabled = true
#   purge_protection_enabled = false

#   keys = {
#     cmk_for_acr = {
#       key_opts = [
#         "decrypt",
#         "encrypt",
#         "sign",
#         "unwrapKey",
#         "verify",
#         "wrapKey"
#       ]
#       key_type = "RSA"
#       name     = "cmk-for-acr"
#       key_size = 2048
#     }
#   }

#   role_assignments = {
#     deployment_user_kv_admin = {
#       role_definition_id_or_name = "Key Vault Administrator"
#       principal_id               = data.azurerm_client_config.current.object_id
#     }
#     acr_kv_admin = {
#       role_definition_id_or_name = "Key Vault Administrator"
#       principal_id               = module.acr_uai.principal_id
#     }
#   }

#   wait_for_rbac_before_key_operations = {
#     create = "60s"
#   }

#   network_acls = {
#     bypass   = "AzureServices"
#     ip_rules = ["${data.http.ip.response_body}/32"]
#   }
# }

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.azure_container_registry.resource_id
  role_definition_name = "AcrPull"
  principal_id         = module.cluster-uai.principal_id
}

#TODO: Are these both (kubelet_acr_pull and aks_acr_pull) needed?
# resource "azurerm_role_assignment" "kubelet_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
# }

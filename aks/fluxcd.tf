# resource "azurerm_kubernetes_cluster_extension" "flux" {
#   name              = "aks-fluxcd"
#   cluster_id        = azurerm_kubernetes_cluster.aks.id
#   extension_type    = "microsoft.flux"
#   release_namespace = "flux-system"

#   configuration_settings = {
#     "image-automation-controller.enabled" = true,
#     "image-reflector-controller.enabled"  = true,
#     "notification-controller.enabled"     = true,
#   }
# }

# resource "azurerm_kubernetes_flux_configuration" "test_app" {
#   name                              = "cluster-config"
#   cluster_id                        = azurerm_kubernetes_cluster.aks.id
#   namespace                         = "cluster-config"
#   scope                             = "cluster"
#   continuous_reconciliation_enabled = true

#   git_repository {
#     url                      = "https://github.com/PixelRobots/aks-gitops-demo"
#     reference_type           = "branch"
#     reference_value          = "main"
#     sync_interval_in_seconds = 60
#   }

#   kustomizations {
#     name                       = "my-kustomization"
#     garbage_collection_enabled = true
#     recreating_enabled         = true
#     sync_interval_in_seconds   = 60
#   }

# }
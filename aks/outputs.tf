# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw

#   sensitive = true
# }

output "kubeconfig" {
  value     = local_file.kubeconfig.content
  sensitive = true
}

output "acr_name" {
  value = module.azure_container_registry.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
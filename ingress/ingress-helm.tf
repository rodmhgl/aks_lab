# resource "azurerm_public_ip" "aks_ingress_ip" {
#   name                = "aks-ingress-ip"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "kubernetes_namespace" "ingress" {
#   metadata {
#     name = "ingress-nginx"
#   }
# }

# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = kubernetes_namespace.ingress.metadata[0].name

#   set {
#     name  = "controller.service.loadBalancerIP"
#     value = azurerm_public_ip.aks_ingress_ip.ip_address
#   }
# }

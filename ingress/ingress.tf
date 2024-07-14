# resource "kubernetes_namespace" "ingress" {
#   metadata {
#     name = "ingress-nginx"
#   }
# }

# resource "kubernetes_service_account" "nginx" {
#   metadata {
#     name      = "nginx"
#     namespace = kubernetes_namespace.ingress.metadata[0].name
#   }
# }

# resource "kubernetes_cluster_role" "nginx" {
#   metadata {
#     name = "nginx-ingress-clusterrole"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "services"]
#     verbs      = ["list", "watch"]
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["nodes"]
#     verbs      = ["get"]
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["services", "endpoints"]
#     verbs      = ["get", "list", "watch"]
#   }

#   rule {
#     api_groups = ["extensions", "networking.k8s.io"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "list", "watch"]
#   }

#   rule {
#     api_groups = ["extensions", "networking.k8s.io"]
#     resources  = ["ingresses/status"]
#     verbs      = ["update"]
#   }

#   rule {
#     api_groups = ["extensions"]
#     resources  = ["ingresses/status"]
#     verbs      = ["update"]
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["configmaps"]
#     verbs      = ["get", "create"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "nginx" {
#   metadata {
#     name = "nginx-ingress-clusterrole-nisa-binding"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.nginx.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.nginx.metadata[0].name
#     namespace = kubernetes_namespace.ingress.metadata[0].name
#   }
# }

# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name      = "nginx-ingress-controller"
#     namespace = kubernetes_namespace.ingress.metadata[0].name
#     labels = {
#       app = "nginx-ingress"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "nginx-ingress"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "nginx-ingress"
#         }
#       }

#       spec {
#         service_account_name = kubernetes_service_account.nginx.metadata[0].name

#         container {
#           name  = "nginx-ingress-controller"
#           image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0"

#           args = [
#             "/nginx-ingress-controller",
#             "--configmap=$(POD_NAMESPACE)/nginx-configuration",
#             "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
#             "--udp-services-configmap=$(POD_NAMESPACE)/udp-services",
#           ]

#           env {
#             name  = "POD_NAME"
#             value_from {
#               field_ref {
#                 field_path = "metadata.name"
#               }
#             }
#           }

#           env {
#             name  = "POD_NAMESPACE"
#             value_from {
#               field_ref {
#                 field_path = "metadata.namespace"
#               }
#             }
#           }

#           ports {
#             container_port = 80
#           }

#           ports {
#             container_port = 443
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "nginx" {
#   metadata {
#     name      = "nginx-ingress-controller"
#     namespace = kubernetes_namespace.ingress.metadata[0].name
#   }

#   spec {
#     type = "LoadBalancer"

#     selector = {
#       app = "nginx-ingress"
#     }

#     port {
#       port        = 80
#       target_port = 80
#     }

#     port {
#       port        = 443
#       target_port = 443
#     }
#   }
# }

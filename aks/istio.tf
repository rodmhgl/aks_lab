# data "kubernetes_service" "istio_ingressgateway" {
#   metadata {
#     name      = "aks-istio-ingressgateway-external"
#     namespace = "aks-istio-ingress"
#   }

#   depends_on = [
#     local_file.kubeconfig,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

# resource "kubernetes_config_map" "istio_prometheus_config" {
#   metadata {
#     name      = "ama-metrics-prometheus-config"
#     namespace = "kube-system"
#   }

#   data = {
#     "prometheus-config" = <<-EOT
#       global:
#         scrape_interval: 30s
#       scrape_configs:
#         - job_name: workload
#           scheme: http
#           kubernetes_sd_configs:
#             - role: endpoints
#           relabel_configs:
#             - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
#               action: keep
#               regex: true
#             - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
#               action: replace
#               target_label: __metrics_path__
#               regex: (.+)
#             - source_labels:
#                 [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
#               action: replace
#               regex: ([^:]+)(?::\d+)?;(\d+)
#               replacement: $1:$2
#               target_label: __address__
#     EOT
#   }

#   depends_on = [
#     local_file.kubeconfig,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

# resource "null_resource" "amg_istio_dashboard" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       az grafana dashboard import \
#         --name ${azurerm_dashboard_grafana.metrics.name} \
#         --resource-group ${azurerm_resource_group.aks.name} \
#         --folder 'Azure Managed Prometheus' \
#         --definition 7630
#     EOT
#   }

#   depends_on = [
#     azurerm_role_assignment.amg_me,
#     azurerm_kubernetes_cluster.aks
#   ]
# }


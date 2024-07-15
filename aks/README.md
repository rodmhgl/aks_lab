# You Probably Shouldn't Be Here

This is a small AKS lab that I'm working on (and may never finish). You can feel free to use it but know that I was **real** lazy in putting it together. I gave absolutely no thought to making this easy to use for others, so... sorry about that. 

The `aks` directory will deploy Azure Kubernetes Service, Azure Container Registry, a Log Analytics Workspace, an Azure Monitor Workspace, Prometheus, and Grafana. 

The `flux` directory will install the flux AKS extension along with a sample GitOps application. 

# Retrieve Service IP

`echo "http://$(kubectl get svc -n itops aks-gitops-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"`
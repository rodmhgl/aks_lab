# Retrieve Service IP

`echo "http://$(kubectl get svc -n itops aks-gitops-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"`
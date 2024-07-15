#!/bin/bash

# Configure flux and GitOps
export TF_VAR_aks_id=$(terraform -chdir=../aks output -raw aks_id )

if [[ "$TF_VAR_aks_id" != *"No outputs found"* ]]; then
    terraform init -upgrade
    terraform apply -auto-approve
    echo "Test pod site:"
    echo "http://$(kubectl get svc -n itops aks-gitops-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
else
    echo -e "\nUnable to retrieve AKS ID from AKS deployment state.\n"
fi


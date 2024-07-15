#!/bin/bash

# Deploy AKS
terraform init -upgrade
terraform apply -auto-approve

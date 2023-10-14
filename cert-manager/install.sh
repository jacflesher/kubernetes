#!/bin/bash

## HELM METHOD
# helm repo add jetstack https://charts.jetstack.io

# helm repo update

# helm install \
#   cert-manager jetstack/cert-manager \
#   --namespace cert-manager \
#   --create-namespace \
#   --version v1.13.1 \
#   --set installCRDs=true


## CURL METHOD
kubectl create namespace cert-manager

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml

kubectl kustomize | kubectl apply -f -

kubectl apply -f rbac.yaml
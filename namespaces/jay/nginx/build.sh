#!/bin/bash

#[ -z "$2" ] && { echo "Must pass CERT file path and KEY file path as ARG 1 and ARG 2, respectively... Aborting."; exit 1; }
#[ -f "$1" ] || { echo "Cert file $1 not found... Aborting."; exit 1; }
#[ -f "$2" ] || { echo "Key file $2 not found... Aborting."; exit 1; }
NS="ns-jay"
kubectl create configmap www-flesher-app-jay-configmap --from-file index.html --namespace $NS
kubectl apply -f deployment.yaml --namespace $NS
kubectl apply -f service.yaml --namespace $NS
kubectl create secret tls www-flesher-app-tls --cert "$1" --key "$2" --namespace $NS
kubectl apply -f ingress-tls.yaml --namespace $NS

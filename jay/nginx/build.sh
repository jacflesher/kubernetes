#!/bin/bash

[ -z "$2" ] && { echo "Must pass CERT file path and KEY file path as ARG 1 and ARG 2, respectively... Aborting."; exit 1; }
[ -f "$1" ] || { echo "Cert file $1 not found... Aborting."; exit 1; }
[ -f "$2" ] || { echo "Key file $2 not found... Aborting."; exit 1; }

kubectl create configmap www-flesher-app-configmap --from-file index.html
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl create secret tls www-flesher-app-tls --cert "$1" --key "$2"
kubectl apply -f ingress-tls.yaml

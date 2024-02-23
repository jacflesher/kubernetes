#!/bin/bash
[ -z $1 ] && { echo "Please enter user as single arg... Aborting."; exit 1; }
kubectl create configmap www-flesher-app-${1}-configmap --from-file index.html --namespace ns-${1}
kubectl apply -f deployment.yaml --namespace ns-${1}
kubectl apply -f service.yaml --namespace ns-${1}
kubectl create secret tls www-flesher-app-${1}-tls --cert ../flesher_app.cer --key ../flesher_app.key --namespace ns-${1}
kubectl apply -f ingress-tls.yaml --namespace ns-${1}

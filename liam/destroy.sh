#!/bin/bash
[ -z $1 ] && { echo "Must pass username as single arg... Exiting."; exit 1; }
kubectl delete configmap www-flesher-app-${1}-configmap --namespace ns-${1}
kubectl delete -f deployment.yaml --namespace ns-${1}
kubectl delete -f service.yaml --namespace ns-${1}
kubectl delete secret tls www-flesher-app-${1}-tls --namespace ns-${1}
kubectl delete -f ingress-tls.yaml --namespace ns-${1}

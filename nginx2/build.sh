#!/bin/bash

kubectl create configmap www-flesher-app-configmap --from-file index.html
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl create secret tls www-flesher-app-tls --cert flesher_app.cer --key flesher_app.key
kubectl apply -f ingress-tls.yaml

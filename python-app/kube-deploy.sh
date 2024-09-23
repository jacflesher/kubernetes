#!/bin/bash

kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f buildpod.yaml
echo "After python-build-pod has completed, run:"
echo "$(tput bold)kubectl delete pod python-build-pod$(tput sgr0)"
echo "$(tput bold)kubectl apply -f pod.yaml$(tput sgr0)"

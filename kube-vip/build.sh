#!/bin/bash
kubectl apply -f kube-vip-cloud-controller.yaml
kubectl create configmap -n kube-system kubevip --from-literal range-global=192.168.0.240-192.168.0.243

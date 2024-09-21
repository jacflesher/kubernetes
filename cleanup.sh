#!/bin/bash

kubectl delete all --all

for i in $(kubectl get configmap | grep -v NAME | grep -v '.crt' | awk -F' ' '{print $1}'); do
    kubectl delete "configmap/${i}"
done

for i in $(kubectl get pv | grep -v NAME | awk -F' ' '{print $1}'); do
    kubectl delete "pv/${i}"
done

for i in $(kubectl get pvc | grep -v NAME | awk -F' ' '{print $1}'); do
    kubectl delete "pvc/${i}"
done

for i in $(kubectl get secrets | grep -v NAME | awk -F' ' '{print $1}'); do
    kubectl delete "secret/${i}"
done

kubectl delete configmap nginx-hello-world-configmap --namespace apps

kubectl create configmap nginx-hello-world-configmap --from-file index.html --namespace apps


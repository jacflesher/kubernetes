#!/bin/bash

if [ -z "$1" ]; then
 echo "Please pass in namespace as single arg... Exiting."
 exit 1
fi
if ! kubectl get "namespace/${1}" &>/dev/null; then
 echo "Invalid namespace... Exiting."
 exit 1
fi

cat <<EOF > kustomization.yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $1
resources:
EOF

for file in $(ls *.yaml | grep -v kustom); do 
  echo "  - $file" >> kustomization.yaml
done

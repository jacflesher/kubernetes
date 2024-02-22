#!/bin/bash
set +x

echo "Apply cert to which namespace?"
kubectl get namespaces | sed 1d | awk -F' ' '{print $1}'
echo
read -r NS

cat <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: $(base64 < ./flesher_app.cer | tr -d '\n')
  tls.key: $(base64 ./flesher_app.key | tr -d '\n')
type: kubernetes.io/tls
EOF

echo "Confirm?"
read -r CONFIRM
[[ "${CONFIRM}" =~ ^(YES|Yes|yes|Y|y)$ ]] || exit 1

cat <<EOF | kubectl apply -f - --server-side --force-conflicts
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: $(base64 < ./flesher_app.cer | tr -d '\n')
  tls.key: $(base64 ./flesher_app.key | tr -d '\n')
type: kubernetes.io/tls
EOF

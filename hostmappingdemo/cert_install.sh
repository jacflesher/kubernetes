#!/bin/bash
set +x

[ $(command -v yq) ] || { echo "Must have 'yq' binary installed... Aborting."; exit 1; }
[ -z "$2" ] && { echo "Must pass CERT file path and KEY file path as ARG 1 and ARG 2, respectively... Aborting."; exit 1; }
[ -f "$1" ] || { echo "Cert file $1 not found... Aborting."; exit 1; }
[ -f "$2" ] || { echo "Key file $2 not found... Aborting."; exit 1; }

#echo "Apply cert to which namespace?"
#kubectl get namespaces | sed 1d | awk -F' ' '{print $1}'
#echo
#read -r NS

NS="ns-jay"

yq <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: $(base64 < "$1" | tr -d '\n')
  tls.key: $(base64 < "$2" | tr -d '\n')
type: kubernetes.io/tls
EOF
echo
echo "Confirm? (Y/n)"
read -r CONFIRM
[[ "${CONFIRM}" =~ ^(YES|Yes|yes|Y|y)$ ]] || exit 1

yq <<EOF | kubectl apply -f - --server-side --force-conflicts
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: $(base64 < "$1" | tr -d '\n')
  tls.key: $(base64 < "$2" | tr -d '\n')
type: kubernetes.io/tls
EOF

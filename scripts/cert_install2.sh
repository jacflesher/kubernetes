#!/bin/bash
set +x

#[ $(command -v argocd-vault-plugin) ] || { echo "Missing 'argocd-vault-plugin'... Exiting."; exit 1; }

echo "Apply cert to which namespace?"
kubectl get namespaces | sed 1d | awk -F' ' '{print $1}'
echo
read -r NS

# export AVP_TYPE=gcpsecretmanager
# gcloud auth application-default login --no-launch-browser

cat <<EOF
apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}

spec:
  defaultCertificate:
    secretName: ${NS}-certificate
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-certificate
  namespace: ${NS}

type: Opaque
data:
  tls.crt: $(base64 < ./flesher_app.cer | tr -d '\n')
  tls.key: $(base64 < ./flesher_app.key | tr -d '\n')
EOF

echo "Confirm?"
read -r CONFIRM
[[ "${CONFIRM}" =~ ^(YES|Yes|yes|Y|y)$ ]] || exit 1


cat <<EOF | kubectl apply -f - --server-side --force-conflicts
apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}

spec:
  defaultCertificate:
    secretName: ${NS}-certificate
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NS}-certificate
  namespace: ${NS}

type: Opaque
data:
  tls.crt: $(base64 < ./flesher_app.cer | tr -d '\n')
  tls.key: $(base64 ./flesher_app.key | tr -d '\n')
EOF

#!/bin/bash
set +x

[ $(command -v argocd-vault-plugin) ] || { echo "Missing 'argocd-vault-plugin'... Exiting."; exit 1; }

echo "Apply cert to which namespace?"
read -r NS

export AVP_TYPE=gcpsecretmanager
gcloud auth application-default login --no-launch-browser

cat <<EOF | argocd-vault-plugin generate -
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
  tls.crt: <path:projects/691569880619/secrets/flesher_app_cer#flesher_app_cer>
  tls.key: <path:projects/691569880619/secrets/flesher_app_key#flesher_app_key>
EOF

echo "Confirm?"
read -r CONFIRM
[[ "${CONFIRM}" =~ ^(YES|Yes|yes|Y|y)$ ]] || exit 1


cat <<EOF | argocd-vault-plugin generate - | kubectl apply -f - --server-side --force-conflicts
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
  tls.crt: <path:projects/691569880619/secrets/flesher_app_cer#flesher_app_cer>
  tls.key: <path:projects/691569880619/secrets/flesher_app_key#flesher_app_key>
EOF

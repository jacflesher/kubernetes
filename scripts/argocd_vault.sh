#!/bin/bash
set -x

if [ -z "$VAULT_ADDR" ]; then 
    read -r -p "Enter vault address (https://host:8200): " VAULT_ADDR
    export VAULT_ADDR
fi
if [ -z "$GH_ENTERPRISE_TOKEN" ]; then
    read -r -p "Enter vault github token: " GH_ENTERPRISE_TOKEN
    export GH_ENTERPRISE_TOKEN
fi
export AVP_TYPE="vault"
export AVP_AUTH_TYPE="github"
export AVP_GITHUB_TOKEN="$GH_ENTERPRISE_TOKEN"
NS="ns-jay"

cat <<EOF | argocd-vault-plugin generate - #--verbose-sensitive-output
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
  tls.crt: <path:secrets/data/k8s/${NS}/certs/certificate#cert|base64encode>
  tls.key: <path:secrets/data/k8s/${NS}/certs/certificate#key|base64encode>
EOF
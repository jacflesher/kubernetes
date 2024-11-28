#!/bin/bash
set +x

if [ -z "$VAULT_ADDR" ]; then 
    echo "Not logged into vault..."
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

# argocd-vault-plugin generate - --verbose-sensitive-output
cat <<EOF | argocd-vault-plugin generate - | yq
---
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: <path:secrets/data/certbot/flesher.app#cert|base64encode>
  tls.key: <path:secrets/data/certbot/flesher.app#key|base64encode>
EOF

echo
echo
echo "Apply changes?"
read -r APPLY

[[ "$APPLY" =~ ^(Yes|YES|yes|y|Y)$ ]] || exit 

cat <<EOF | argocd-vault-plugin generate - | kubectl apply -f -
---
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: ${NS}-tlsstore
  namespace: ${NS}
data:
  tls.crt: <path:secrets/data/certbot/flesher.app#cert|base64encode>
  tls.key: <path:secrets/data/certbot/flesher.app#key|base64encode>
EOF
#!/bin/bash
[ $(command -v argocd-vault-plugin) ] || echo "Missing 'argocd-vault-plugin'... Exiting."
[ $(command -v argocd-vault-plugin) ] || exit 1
export AVP_TYPE=gcpsecretmanager
gcloud auth application-default login --no-launch-browser
cat secret.yaml | argocd-vault-plugin generate -
echo "Confirm?"
read -r CONFIRM
[[ "${CONFIRM}" =~ ^(YES|Yes|yes|Y|y)$ ]] || exit 1
cat secret.yaml | argocd-vault-plugin generate - |kubectl apply -f - --server-side --force-conflicts

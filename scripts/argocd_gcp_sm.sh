#!/bin/bash
set +x

if ! gcloud auth application-default print-access-token &>/dev/null; then
    gcloud auth application-default login --no-launch-browser
fi

export AVP_TYPE="gcpsecretmanager"

NS="ns-jay"

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
  tls.crt: <path:projects/691569880619/secrets/flesher_app_cer#flesher_app_cer|base64decode>
  tls.key: <path:projects/691569880619/secrets/flesher_app_key#flesher_app_key|base64encode>
EOF
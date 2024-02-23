#!/bin/bash
set +x


# Set VAR
if [ ! "${1}" ]; then
  echo "Please pass username as single arg... Exiting."
  exit 1
fi



# Build rbac.yaml for new namespace, role, service account, and secret
cat <<EOF | kubectl delete -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ns-${1}
  labels:
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/enforce: restricted
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: sa-${1}
  namespace: ns-${1}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: role-${1}
  namespace: ns-${1}
rules:
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - "*"
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rb-${1}
  namespace: ns-${1}
subjects:
  - kind: ServiceAccount
    name: sa-${1}
    namespace: ns-${1}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: role-${1}
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-${1}
  namespace: ns-${1}
  annotations:
    kubernetes.io/service-account.name: sa-${1}
type: kubernetes.io/service-account-token
EOF


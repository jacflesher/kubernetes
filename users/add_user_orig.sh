#!/bin/bash
set -x


# Set VAR
if [ ! "${1}" ]; then
  echo "Please pass usernname as single arg... Exiting."
  exit 1
fi

DIR="$(pwd)"

# Build rbac.yaml for new namespace, role, service account, and secret
cat <<EOF | kubectl apply -f -
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


# build new ~/.kube/config file
# echo 
# echo "$(tput setaf 196)Save this file to ~/.kube/config$(tput sgr0)"
# echo


 
echo "apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat "${DIR}/ca.dat")
    server: https://192.168.0.240:6443
  name: default
contexts:
- context:
    cluster: default
    namespace: ns-${1}
    user: sa-${1}
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: sa-${1}
  user:
    token: $(kubectl get secret secret-${1} -o jsonpath={.data.token} --namespace ns-${1} | base64 -d)" | yq


sudo kubectl config set-credentials "sa-${1}" --token="$(kubectl get secret secret-${1} -o jsonpath={.data.token} --namespace ns-${1} | base64 -d)"


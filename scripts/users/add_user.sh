#!/bin/bash
set +x


# Set VAR
if [ ! "${1}" ]; then
  echo "Please pass new user as single arg... Exiting."
  exit 1
fi

# Build rbac.yaml and deploying new sa and ns
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Namespace
metadata:
  name: ns-${1}
  labels:
    #pod-security.kubernetes.io/audit: restricted
    #pod-security.kubernetes.io/enforce: restricted
    #pod-security.kubernetes.io/audit: baseline
    #pod-security.kubernetes.io/enforce: baseline
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

echo
echo
echo "apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(yq .clusters[].cluster.certificate-authority-data /etc/rancher/k3s/k3s.yaml)
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
echo
echo
echo
echo "Change context user:"
echo "sudo kubectl config set-credentials \"sa-${1}\" --token \"$(kubectl get secret secret-${1} -o jsonpath={.data.token} --namespace ns-${1} | base64 -d)\""
echo
echo "Change context namespace:"
echo "k3s: sudo kubectl config set-context default --cluster default --namespace ns-${1}"
echo "minikube: sudo kubectl config set-context minikube --cluster minikube --namespace ns-${1}"
echo
echo

#!/bin/bash
set +x

[ -z $1 ] && { echo "Please enter user as single arg... Aborting."; exit 1; }
kubectl create configmap www-flesher-app-${1}-configmap --from-file index.html --namespace ns-${1}
kubectl create secret tls www-flesher-app-${1}-tls --cert ../flesher_app.cer --key ../flesher_app.key --namespace ns-${1}

yq <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ns-${1}
  name: www-flesher-app-${1}
spec:
  selector:
    matchLabels:
      app: www-flesher-app-${1}
  replicas: 1
  template:
    metadata:
      labels:
        app: www-flesher-app-${1}
    spec:
      containers:
      - name: www-flesher-app-${1}
        image: nginx
        securityContext:
          runAsNonRoot: true
          allowPrivilegeEscalation: false
          seccompProfile:
            type: RuntimeDefault
          capabilities:
            drop:
              - ALL
        ports:
        - containerPort: 80
        volumeMounts:
        - name: www-flesher-app-${1}
          mountPath: /usr/share/nginx/html
      volumes:
      - name: www-flesher-app-${1}
        configMap:
          name: www-flesher-app-${1}-configmap
---
apiVersion: v1
kind: Service
metadata:
  name: www-flesher-app-${1}
  namespace: ns-${1}
spec:
  allocateLoadBalancerNodePorts: true
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  selector:
    app: www-flesher-app-${1}
  sessionAffinity: None
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: 192.168.0.240
    - ip: 192.168.0.241
    - ip: 192.168.0.242
    - ip: 192.168.0.243
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: www-flesher-app-${1}-ingress
  namespace: ns-${1}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /${1}
spec:
  tls:
  - hosts:
    - "*.flesher.app"
    secretName: www-flesher-app-${1}-tls
  rules:
  - host: "*.flesher.app"
    http:
      paths:
      - path: /${1}
        pathType: Prefix
        backend:
          service:
            name: www-flesher-app-${1}
            port:
              number: 80
EOF

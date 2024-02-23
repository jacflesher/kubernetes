#!/bin/bash
set +x

USER=$(pwd | awk -F'/' '{print $NF}')

#[ -z $1 ] && { echo "Please enter user as single arg... Aborting."; exit 1; }
kubectl create configmap www-flesher-app-${USER}-configmap --from-file index.html --namespace ns-${USER}
kubectl create secret tls www-flesher-app-${USER}-tls --cert ../flesher_app.cer --key ../flesher_app.key --namespace ns-${USER}

yq <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ns-${USER}
  name: www-flesher-app-${USER}
spec:
  selector:
    matchLabels:
      app: www-flesher-app-${USER}
  replicas: 1
  template:
    metadata:
      labels:
        app: www-flesher-app-${USER}
    spec:
      containers:
      - name: www-flesher-app-${USER}
        image: nginx
        #securityContext:
          #runAsUser: 100
          #runAsNonRoot: true
          #allowPrivilegeEscalation: false
          #seccompProfile:
            #type: RuntimeDefault
          #capabilities:
            #drop:
              #- ALL
        ports:
        - containerPort: 8087
        volumeMounts:
        - name: www-flesher-app-${USER}
          mountPath: /usr/share/nginx/html
      volumes:
      - name: www-flesher-app-${USER}
        configMap:
          name: www-flesher-app-${USER}-configmap
---
apiVersion: v1
kind: Service
metadata:
  name: www-flesher-app-${USER}
  namespace: ns-${USER}
spec:
  allocateLoadBalancerNodePorts: true
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: http
    port: 8087
    protocol: TCP
    targetPort: 80
  - name: https
    port: 44387
    protocol: TCP
    targetPort: 443
  selector:
    app: www-flesher-app-${USER}
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
  name: www-flesher-app-${USER}-ingress
  namespace: ns-${USER}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /${USER}
spec:
  tls:
  - hosts:
    - "*.flesher.app"
    secretName: www-flesher-app-${USER}-tls
  rules:
  - host: "*.flesher.app"
    http:
      paths:
      - path: /${USER}
        pathType: Prefix
        backend:
          service:
            name: www-flesher-app-${USER}
            port:
              number: 8087
EOF

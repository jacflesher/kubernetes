#!/bin/bash

VIP=192.168.0.244
INTERFACE=eth0
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")

ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip manifest pod \
--interface $INTERFACE \
--address $VIP \
--controlplane \
--services \
--arp \
--leaderElection | \
tee kube-vip.yaml

curl -s -o rbac.yaml https://kube-vip.io/manifests/rbac.yaml
kubectl apply -f rbac.yaml

ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip manifest daemonset \
    --interface $INTERFACE \
    --address $VIP \
    --inCluster \
    --taint \
    --controlplane \
    --services \
    --arp \
    --leaderElection

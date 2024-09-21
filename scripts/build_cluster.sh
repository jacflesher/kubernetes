#!/bin/bash
set +x

if [[ "$(hostname)" != *master* ]]; then
	echo "This script must be run from the kubernetes master node... Exiting."
	exit 1
fi
	
if [[ ! $(which k3s) ]]; then
	echo "Installing k3s on master node..."
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=servicelb" sh -
	#curl -sfL https://get.k3s.io | sh -
else
	echo "k3s already installed on master node..."
fi

SSH_COMMAND="curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.240:6443 K3S_TOKEN=\"$(sudo cat /var/lib/rancher/k3s/server/node-token)\" sh -"

for i in 241 242 243; do
	if [[ ! $(ssh -A jay@192.168.0.${i} which k3s) ]]; then
		echo "Installing k3s on 192.168.0.${i}..."
		ssh -A jay@192.168.0.${i} ${SSH_COMMAND}
	else
		echo "k3s already installed on 192.168.0.${i}..."
	fi
done

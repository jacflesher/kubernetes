#!/bin/bash
set +x


if [[ $(which k3s) ]]; then
	echo "Uninstalling on master host..."
	sudo /usr/local/bin/k3s-uninstall.sh
else
	echo "k3s not installed on master host..."
fi

SSH_COMMAND="sudo /usr/local/bin/k3s-agent-uninstall.sh"
for i in 241 242 243; do 
	if [[ $(ssh -A jay@192.168.0.${i} which k3s) ]]; then
		echo "Uninstalling k3s on node 192.168.0.${i}..."
		ssh -A jay@192.168.0.${i} ${SSH_COMMAND}
	else
		echo "k3s not installed on 192.168.0.${i}..."
	fi
done

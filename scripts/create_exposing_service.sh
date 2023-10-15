
if [ ! $2 ]; then
	echo "Please pass deployment name as arg 1 and namespace as arg 2... Exiting."
	exit 1
fi

kubectl expose deployment "${1}" --type=LoadBalancer --name="${1}-service" --namespace ${2}



if [ ! $1 ]; then
	echo "Please pass deployment name as single arg... Exiting."
	exit 1
fi

kubectl expose deployment "${1}" --type=LoadBalancer --name=${1}-service


#!/bin/bash +x

[ -z "$1" ] && { echo "Must pass common name as single arg... Exiting."; exit 1; }
openssl s_client -showcerts -connect "${1}:443" < /dev/null | openssl x509 -outform PEM > "${1}.crt" 
echo; echo;
echo "$(tput bold)${1}.crt$(tput sgr0)"
echo
cat "${1}.crt"
echo

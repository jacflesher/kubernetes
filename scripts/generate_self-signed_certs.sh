#!/bin/bash
set +x

CN="$1"

cat <<EOF > openssl.cnf
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca   # Enable v3_ca extensions

[ req_distinguished_name ]
commonName = Common Name (CN)

[ v3_ca ]
subjectAltName = DNS:${CN}   # Add the SAN extension
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${CN}.key" -out "${CN}.cer" -subj "/CN=${CN}/O=${CN}" -extensions v3_ca -config openssl.cnf 

if [[ "$?" == 0 ]]; then 
	echo "Certs generated successfully..."
fi

rm openssl.cnf &>/dev/null

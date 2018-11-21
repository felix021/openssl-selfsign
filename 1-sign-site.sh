#!/bin/bash

set -e

function color_text()
{
    echo -e "\\x1b[33;44m$1\\x1b[0m"
}

cd `dirname $0`
cwd=`pwd`

cd ./cert/

days=365

domain=$1
if [ -z "$domain" ]; then
    echo "usage: $0 <domain>"
    exit 1
fi

if [ -d site/$domain ]; then
    echo "Fail: site/$domain exists."
    exit 1
fi
mkdir -p site/$domain

subject="/O=$domain/CN=*.$domain/subjectAltName=*.$domain/emailAddress=admin@$domain"

filename=site/$domain/cert

openssl genrsa -out ${filename}.key 2048
openssl req -new -key ${filename}.key -out ${filename}.csr -subj "$subject"
openssl x509 -req -in ${filename}.csr -CA cacert.pem -CAkey private/cakey.pem -CAcreateserial -out ${filename}.crt -days $days -sha256

sed -e "s/__DOMAIN__/$domain/g" -e "s=__ROOT__=$cwd=" ../template.conf > ./site/$domain/nginx.conf

echo
echo "Successfully signed https cert for `color_text $domain`:"
echo
echo "  cert file: `color_text cert/${filename}.crt`"
echo
echo "  try nginx config: `color_text cert/site/$domain/nginx.conf`"
echo

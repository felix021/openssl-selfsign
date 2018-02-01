#!/bin/bash

cd `dirname $0`
cwd=`pwd`
CA_ROOT=$cwd/ca/

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

subject="/O=$domain/CN=$domain/subjectAltName=*.$domain/emailAddress=admin@$domain"

filename=site/$domain/cert

openssl genrsa -out ${filename}.key 2048
openssl req -new -key ${filename}.key -out ${filename}.csr -subj "$subject"
openssl x509 -req -in ${filename}.csr -CA $CA_ROOT/ca.crt -CAkey $CA_ROOT/ca.key -CAcreateserial -out ${filename}.crt -days 365 -sha256

sed -e "s/__DOMAIN__/$domain/g" -e "s=__ROOT__=/$cwd=" ./html/template.conf > ./html/nginx.conf

echo "Successfully signed https cert for $domain:"
echo "  cert file: ${filename}.crt"
echo "  try nginx config: html/nginx.conf"

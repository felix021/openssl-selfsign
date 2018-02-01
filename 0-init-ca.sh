#!/bin/bash

cd `dirname $0`
if [ -e ./ca/ca.key ]; then
    echo 'Fail: ca.key exists.'
    exit 1
fi

domain=$1
if [ -z "$domain" ]; then
    echo "usage: $0 <domain>"
    exit 0
fi
echo "domain=$domain" > config.sh

mkdir -p ca

subject="/O=$domain/CN=$domain/emailAddress=admin@$domain"

openssl genrsa -out ./ca/ca.key 4096
openssl req -new -x509 -days 3650 -key ./ca/ca.key -out ./ca/ca.crt -subj "$subject" 
openssl req -new -x509 -key ./ca/ca.key -out ./ca/ca.pem -subj "$subject"

./1-sign-site.sh $domain

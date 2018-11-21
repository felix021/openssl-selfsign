#!/bin/bash

set -e

cd `dirname $0`

mkdir -p ./cert
cd ./cert

path=./private/
if [ -e $path/cakey.pem ]; then
    echo "Fail: cakey exists."
    exit 1
fi
mkdir -p $path

domain=$1
if [ -z "$domain" ]; then
    echo "usage: $0 <domain>"
    exit 0
fi
echo "domain=$domain" > config.sh

serial_no=00
echo $serial_no > serial

days=3650

subject="/O=$domain/CN=$domain/emailAddress=admin@$domain"

openssl genrsa -out $path/cakey.pem 4096
openssl req -new -key $path/cakey.pem -out careq.pem -subj "$subject"
openssl req -new -x509 -days $days -key $path/cakey.pem -out ./ca.crt -subj "$subject" 
openssl req -new -x509 -days $days -key $path/cakey.pem -set_serial $serial_no -out ./cacert.pem -subj "$subject"
openssl x509 -in cacert.pem -out cacert.cer -outform DER

timestr=`openssl x509 -in ./cacert.pem -serial -enddate | grep notAfter | awk -F= '{print $2}'`

time=`date --date="$timestr" +%y%m%d%H%M%S`

echo -e "V\t${time}Z\t\t${serial_no}\tcacert.pem\t$subject" > index.txt
touch index.txt.attr

echo $serial_no > crlnumber
openssl ca -config ../openssl.cnf -gencrl -out crl.pem

../1-sign-site.sh $domain

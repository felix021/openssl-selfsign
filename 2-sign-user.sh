#!/bin/bash

set -e

cd `dirname $0`

function color_text()
{
    echo -e "\\x1b[33;44m$1\\x1b[0m"
}

cd ./cert
source config.sh

CA_ROOT=./private/
serial_file=./serial

#证书有效天数
days=365

username=$1
if [ -z "$username" ]; then
    echo "usage: $0 <username>"
    exit 1
fi

dir=newcerts/$username
if [ -d $dir ]; then
    echo "Failed: $username already used"
    exit
fi
mkdir -p $dir

touch $serial_file
serial_no=`cat $serial_file`
if [ -z "$serial_no" ]; then
    serial_no=0
fi

serial_no=`echo $serial_no | awk '{printf("%04d", $1 + 1)}'`
echo $serial_no > $serial_file
touch $dir/$serial_no

#subject="/C=US/ST=California/L=Las Vegas/O=$domain/OU=$domain/CN=$username/emailAddress=$username@$domain"
#simpler version
subject="/O=$domain/CN=$username/emailAddress=$username@$domain"

filename=$dir/$username
pass=`head -c 32 /dev/urandom | md5sum | head -c 8`
echo $pass > ${filename}.pass

openssl genrsa -out ${filename}.key 4096
openssl req -new -key ${filename}.key -out ${filename}.csr -subj "$subject"
openssl x509 -req -days $days -in ${filename}.csr -CA cacert.pem -CAkey $CA_ROOT/cakey.pem -set_serial $serial_no -out ${filename}.crt
openssl pkcs12 -export -in ${filename}.crt -inkey ${filename}.key -out ${filename}.p12 -password pass:$pass

timestr=`openssl x509 -in ${filename}.crt -serial -enddate | grep notAfter | awk -F= '{print $2}'`
time=`date --date="$timestr" +%y%m%d%H%M%S`
echo -e "V\t${time}Z\t\t$serial_no\t${filename}.crt\t$subject" >> index.txt

echo
echo -e "Successfully signed for user `color_text $username`:"
echo
echo -e "  cert file: `color_text cert/${filename}.p12`"
echo
echo -e "  password: `color_text $pass`"
echo 

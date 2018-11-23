#!/bin/bash

set -e

cd `dirname $0`

function color_text()
{
    echo -e "\\x1b[33;44m$1\\x1b[0m"
}

cd ./cert
source config.sh

serial_file=./serial
serial_no=`echo $((16#$(cat $serial_file) + 1)) | awk '{printf("%02x", $1)}'`

#证书有效天数
days=365

username=$1
if [ -z "$username" ]; then
    echo "usage: $0 <username>"
    exit 1
fi

function listCert()
{
    username=$1
    echo "Certificates already issued for [$username]: "
    for i in newcerts/$username@*;
    do
        timestr=`openssl x509 -in $i/crt.pem -serial -enddate | grep notAfter | awk -F= '{print $2}'`
        time=`date --date="$timestr" +%Y-%m-%d\ %H:%M:%S`
        echo -e "    serial=${i/newcerts\/$username@/}\t issued at $time"
    done
}

serial_no=`echo $((16#$(cat serial))) | awk '{printf("%02x", $1 + 1)}'`

check=`echo newcerts/$username@*`
if [ "$check" != 'newcerts/'$username'@*' ]; then
    listCert $username
    read -p "Issue a new certificate? (yes/no)" confirm
    if [ "$confirm" != "yes" ]; then
        echo
        echo "Aborted."
        echo
        exit
    fi
fi

dir=newcerts/$username@$serial_no
mkdir -p $dir

#subject="/C=US/ST=California/L=Las Vegas/O=$domain/OU=$domain/CN=$username/emailAddress=$username@$domain"
# fill serial_no in the Country field, to make subject different for each cert.
subject="/C=$serial_no/O=$domain/CN=$username/emailAddress=$username@$domain"

filename=$dir/$username
pass=`head -c 32 /dev/urandom | md5sum | head -c 8`
echo $pass > $dir/password

openssl genrsa -out $dir/key.pem 2048
openssl req -new -key $dir/key.pem -out $dir/csr.pem -subj "$subject"
openssl x509 -req -days $days -in $dir/csr.pem -CA cacert.pem -CAkey ./private/cakey.pem -CAserial serial -out $dir/crt.pem
openssl pkcs12 -export -in $dir/crt.pem -inkey $dir/key.pem -out $dir/cert.p12 -password pass:$pass

serial_no=`openssl x509 -in $dir/crt.pem -serial -enddate | grep serial | awk -F= '{print $2}'`
timestr=`openssl x509 -in $dir/crt.pem -serial -enddate | grep notAfter | awk -F= '{print $2}'`
time=`date --date="$timestr" +%y%m%d%H%M%S`
echo -e "V\t${time}Z\t\t$serial_no\t$dir/crt.pem\t$subject" >> index.txt

echo
echo -e "Successfully signed for user `color_text $username`:"
echo
echo -e "  cert file: `color_text cert/$dir/cert.p12`"
echo
echo -e "  password: `color_text $pass`"
echo 

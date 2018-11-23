#!/bin/bash

set -e

cd `dirname $0`

function color_text()
{
    echo -e "\\x1b[33;44m$1\\x1b[0m"
}

function listCert()
{
    username=$1
    for i in newcerts/$username@*;
    do
        timestr=`openssl x509 -in $i/crt.pem -serial -enddate | grep notAfter | awk -F= '{print $2}'`
        time=`date --date="$timestr" +%Y-%m-%d\ %H:%M:%S`
        echo -e "    serial=${i/newcerts\/$username@/}\t issued at $time"
    done
}

cd ./cert
source config.sh

username=$1
if [ -z "$username" ]; then
    echo "usage: $0 <username> [silent]"
    exit 1
fi

check=`echo newcerts/$username@*`
if [ ! -d newcerts/$username -a "$check" == 'newcerts/'$username'@*' ]; then
    echo "no cert issued for $username"
    exit 1
fi

file=newcerts/$username/crt.pem
if [ ! -f "$file" ]; then
    listCert $username
    read -p "Which one do you want to revoke? serial = " serial
    file=newcerts/$username@$serial/crt.pem
    echo $file
    if [ ! -f $file ]; then
        echo "Error: invalid serial"
        exit 1
    fi
fi

if [ "$2" != "silent" ]; then
    echo
    read -p "Are you sure to revoke certificate '${file/newcerts\//}'? (yes/no) " confirm
    if [ "$confirm" != "yes" ]; then
        echo
        echo "Aborted."
        exit 0
    fi
fi

openssl ca -config ../openssl.cnf -revoke $file
openssl ca -config ../openssl.cnf -gencrl -out crl.pem

echo
echo -e "Successfully revoked user `color_text $username`:"
echo
echo -e "  updated crl file: `color_text cert/crl.pem`"
echo
echo -e "  don't forget to restart nginx."
echo

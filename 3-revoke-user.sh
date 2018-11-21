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

username=$1
if [ -z "$username" ]; then
    echo "usage: $0 <username> [silent]"
    exit 1
fi

file=newcerts/$username/$username.crt
if [ ! -f "$file" ]; then
    echo "Error: invalid user '$username'"
    exit 1
fi

if [ "$2" != "silent" ]; then
    echo
    read -p "Are you sure to revoke user '$username'? (yes/no) " confirm
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

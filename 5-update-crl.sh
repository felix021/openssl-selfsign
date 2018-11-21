#!/bin/bash

set -e

cd `dirname $0`

function color_text()
{
    echo -e "\\x1b[33;44m$1\\x1b[0m"
}
cd ./cert
source config.sh

openssl ca -config ../openssl.cnf -gencrl -out crl.pem

echo
echo -e "Successfully updated crl file: `color_text cert/crl.pem`"
echo
echo -e "  don't forget to restart nginx."
echo

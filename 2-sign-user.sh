#!/bin/bash

cd `dirname $0`
cwd=`pwd`

source config.sh

mkdir -p user
CA_ROOT=$cwd/ca/
serial_file=$cwd/serial_no

username=$1
if [ -z "$username" ]; then
    echo "usage: $0 <username>"
    exit 1
fi

touch $serial_file
serial_no=`cat $serial_file`
if [ -z "$serial_no" ]; then
    serial_no=1
else
    serial_no=$(($serial_no+1))
fi
echo $serial_no > $serial_file

dir=user/$serial_no
if [ -d $dir ]; then
    echo "Failed: $serial_no already used"
    exit
fi

#subject="/C=US/ST=California/L=Las Vegas/O=$domain/OU=$domain/CN=$username/emailAddress=$username@$domain"
#simpler version
subject="/O=$domain/CN=$username/emailAddress=$username@$domain"

mkdir -p $dir
filename=user/$serial_no/$username
pass=`python -c "import zlib, random; print '%08x' % abs(zlib.crc32(open('/dev/random').read(8)))"`
echo $pass > ${filename}.pass

openssl genrsa -out ${filename}.key 4096
openssl req -new -key ${filename}.key -out ${filename}.csr -subj "$subject"
openssl x509 -req -days 365 -in ${filename}.csr -CA $CA_ROOT/ca.crt -CAkey $CA_ROOT/ca.key -set_serial $serial_no -out ${filename}.crt
openssl pkcs12 -export -clcerts -certfile $CA_ROOT/ca.crt -in ${filename}.crt -inkey ${filename}.key -out ${filename}.p12 -password pass:$pass

echo "succussfully signed user $username:"
echo "  cert file: ${filename}.p12"
echo "  password: $pass"

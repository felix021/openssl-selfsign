#!/bin/bash

set -e

cd `dirname $0`/cert

openssl crl -in crl.pem -text

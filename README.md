OPENSSL SELFSIGN TOOLS
====

[文档: 中文版](README-cn.md)

Usage:

# generate ca:

    $ ./0-init-ca.sh <yourdomain.com>

At the end of this script, `./1-sign-site.sh yourdomain.com` will be called
to generate https certificate for `yourdomain.com` and `*.yourdomain.com`

# set up nginx

Refer to `cert/site/<yourdomain.com>/nginx.conf`

**NOTICE**: by default, `crl.pem` expires in 365 days, don't forget to update it in time, otherwise nginx will **REJECT ALL** requests . If you don't need it, comment out that line.

# generate https certificate:

You can now use https certificates located at `cert/site/yourdomain.com/`.

If you wish to sign for another domain, you can try this:

    $ ./1-sign-site.sh <another-domain.com>

# generate client side certificate:

    $ ./2-sign-user.sh <cert-holder-name>

A PKCS#12 certificate (p12 file, and corresponding password) will be assiged to the user, which can be imported in both Windows, MacOS, iOS, Android.

Each certificate will be assigned a unique serial number (used in crl.pem).

Tips: For iOS, the Mail app (pre-installed with iOS) helps.

# revoke certificate

    $ ./3-revoke-user.sh <cert-holder-name>

Type the serial number to choose the certificate you want to revoke, or:

    $ ./3-revoke-user.sh <cert-holder-name@serial>

`./cert/crl.pem` will be updated. Replace with it in your web server's config,
and don't forget to reload your web server.

Tips:

* You can adjust the default value in `openssl.cnf +74: "default_crl_days"`

* If you need to recover a revoked certificate, find the corresponding line in `cert/index.php`, change the preceding 'R'(Revoked) to 'V'(Valid), and delete the 3rd field(time of revoking), and run this command under `./cert` to update `crl.pem`:

    user@host ./cert$ openssl ca -config ../openssl.cnf -gencrl -out crl.pem

# show detailed certificate revoke list

    $ ./4-list-revoked-cert.sh

It will parse the crl.pem to show the list(serial no) of revoked cerificates.

# update crl file

    $ ./5-update-crl.sh

`./cert/crl.pem` will be updated. Replace with it in your web server's config,
and don't forget to reload your web server.

CRL file should get updated periodly, and better automatically.

# test

You can import the PKCS#12 cert and test with your web browser; to be simpler, you can also try this:

    $ ./6-curl-test-request.sh <cert-holder-name@serial>

If everything's fine, you will see something like this (output by `html/index.php`):

```
HTTP/1.1 200 OK
Server: nginx/1.14.0 (Ubuntu)
Date: Wed, 21 Nov 2018 18:45:25 GMT
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive

[SUCCESS] emailAddress=test1@dev.com,CN=test1,O=dev.com

$_SERVER = array (
      ...
      'SSL_DN' => 'emailAddress=test1@dev.com,CN=test1,O=dev.com',
      'VERIFIED' => 'SUCCESS',
      ...
)
```

# Special thanks

[How to Create a CA and User Certificates for Your Organization](https://help.cloud.fabasoft.com/index.php?topic=doc/How-to-Create-a-CA-and-User-Certificates-for-Your-Organization-in-Fabasoft-Cloud/certificate-revocation-list-via-openssl.htm)

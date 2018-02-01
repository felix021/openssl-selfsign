OPENSSL SELFSIGN TOOLS
====

Usage:

# generate ca:

    $ ./0-init-ca.sh <yourdomain.com>

At the end of this script, `./1-sign-site.sh yourdomain.com` will be called
to generate https certificate for `yourdomain.com` and `*.yourdomain.com`

# set up nginx

refer to `html/nginx.conf`

# generate https certificate:

You can now use certs located at `site/yourdomain.com/`.

If you wish to sign for another domain, you can try this:

    $ ./1-sign-site.sh <another-domain.com>

# generate client side certificate:

    $ ./2-sign-user.sh <your-name>

Each cert will be assigned a serial no for later use in crl file (if necessary)

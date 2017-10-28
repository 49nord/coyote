coyote: Automatic let's encrypt / ACME certificate renewal
==========================================================

`coyote` renews [let's encrypt](https://letsencrypt.org/) certificates
automatically using the ACME protocol. It only performs the necessary steps to
renew the certificates, and is usually used in tandem with systemd and nginx.


Quick start
-----------

TBW


Command-line use
----------------

`coyote` takes domains to renew as command-line arguments (you can list
multiple):

```
coyote mydomain.example.com [...]
```

Once started, it will first check if a certificate file named
`/etc/ssl/mydomain.example.com.crt` exists. If it does and its expiration date
is at least 30 days in the future, no action will be taken.

If the certificate does not exist or will expire soon, `coyote` will generate a
new keypair (stored as **`/etc/ssl/private/mydomain.example.com.pem`** for the
private key and `/etc/ssl/mydomain.example.com.crt` for the public key),
generate a certificate signing request (`/etc/coyote/mydomain.example.com.csr`)
and use these items to create a new certificate signed by let's encrypt.

The resulting certificate will be stored as
**`/etc/ssl/mydomain.example.com.crt'**, a chain version is available at
**`/etc/ssl/mydomain.example.com.chain.crt'**.


Webserver configuration
-----------------------


### nginx

TBW


Enabling using systemd
----------------------

TBW


Security
--------

`coyote has three dependencies: [acme-tiny](https://github.com/diafygi/acme-
`tiny), [requests](docs.python-requests.org/) and OpenSSL. acme-tiny is meant to be
`reviewed personally, though it is also installable as a Debian packages called
`[acme-tiny](https://packages.debian.org/search?keywords=acme-tiny). requests
`can be installed on Debian in the form of [python3-requests](https://packages.
`debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=p
`ython3-requests). Alternatively it can also be installed "manually" using
`virtualenv.

Since `coyote` is a single file executable, it can and should also be reviewed
manually, similar to `acme-tiny`.

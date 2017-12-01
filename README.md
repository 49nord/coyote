coyote: Automatic let's encrypt / ACME certificate renewal
==========================================================

`coyote` renews [let's encrypt](https://letsencrypt.org/) certificates automatically using the ACME protocol. It only performs the necessary steps to renew the certificates, and is usually used in tandem with systemd and nginx.

Quick start
-----------

First, install coyote. The recommended way is to install the tiny debian package included in this repository; see [releases](https://github.com/49nord/coyote/releases) for the latest version:

```
# dpkg -i coyote_VERSION.deb
```

Note that the package does not perform destructive operations, change configuration or start services by itself.

Once the package is installed, nginx (or another webserver) needs to be configured. The recommended setup is to redirect all HTTP requests to HTTPS requests, except for those required by let's encrypt (`http://mydomain.example.com/.well-known/acme-challenge`). The debian package ships with a configuration that does exactly that, on Debian systems it can be enabled as follows:

```
# rm /etc/nginx/sites-enabled/default
# ln -s /etc/nginx/sites-available/00_acme-challenge /etc/nginx/sites-enabled/00_acme-challenge
# systemctl reload nginx
```

See the Webserver configuration section for details.

With the nginx in place, `coyote` can be setup. The debian package will install a systemd template unit named `coyote@`, including a timer. The following commands set up automatic certificate generation and renewal via let's encrypt:

```
# systemctl enable coyote@mydomain.example.com.timer
# systemctl start coyote@mydomain.example.com.timer
# systemctl start coyote@mydomain.example.com.service
```

Enabling the `.timer` will cause the timer to be started on the next boot, while the start command causes it to also be started right now. The `start` command targeting the `.service` will immediately run coyote once, resulting in a certificate to be generated.

`coyote` will be run once per day at 3 am and check if the certificate has less than 30 days to live. If that is the case, it will attempt to generate a new one.

## Manual installation

TBW


Command-line use
----------------

`coyote` takes domains to renew as command-line arguments (you can list multiple):

```
# coyote mydomain.example.com [...]
```

Once started, it will first check if a certificate file named `/etc/ssl/mydomain.example.com.crt` exists. If it does and its expiration date is at least 30 days in the future, no action will be taken.

If the certificate does not exist or will expire soon, `coyote` will generate a new keypair (stored as **`/etc/ssl/private/mydomain.example.com.pem`** for the private key and `/etc/ssl/mydomain.example.com.crt` for the public key), generate a certificate signing request (`/etc/coyote/mydomain.example.com.csr`) and use these items to create a new certificate signed by let's encrypt.

The resulting certificate will be stored as **`/etc/ssl/mydomain.example.com.crt`**, a chain version is available at **`/etc/ssl/mydomain.example.com.chain.crt`**.


Webserver configuration
-----------------------


### nginx

TBW


Enabling using systemd
----------------------

TBW


Security
--------

`coyote` has three dependencies: [acme-tiny](https://github.com/diafygi/acme-tiny), [requests](docs.python-requests.org/) and OpenSSL. `acme-tiny` is meant to be reviewed personally, though it is also installable as a Debian packages called [acme-tiny](https://packages.debian.org/search?keywords=acme-tiny). `requests` can be installed on Debian in the form of [python3-requests](https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=python3-requests). Alternatively it can also be installed "manually"using virtualenv.

Since `coyote` is a single file executable, it can and should also be reviewed manually, similar to `acme-tiny`.

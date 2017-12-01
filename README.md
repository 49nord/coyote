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

The resulting certificates will then be stored as `/etc/ssl/private/mydomain.example.com.pem` (key), `/etc/ssl/mydomain.example.com.crt` (certificate) and `/etc/ssl/mydomain.example.com.chain.crt` (certificate chain with the necessary intermediate certificates).

For multiple domains on the same machine, see the "Scheduling coyote" section below.

## Manual installation

The `.deb` is fairly simple but on different distros coyote can be used standalone. The `coyote` python script assumes that `acme-tiny` and `requests` are installed.

The systemd units are straightforward and can manually be installed as well. The `00_acme-challenge` is a suggestion for an nginx configuration.


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

Coyote assumes that the directory `/var/www/html/.well-known/acme-challenge` on the machine it itself is running will be visible via HTTP on the domain name being registered. No assumptions are made beyond. Challanges to prove ownership required by the ACME protocol are put into thus directory.

### nginx

On debian systems, nginx and other webservers can be configured using the `sites-available` and `sites-enabled` directory model, with configuration file fragments put into `sites-available` and then enabled by symlinking the fragment into `sites-enabled`.

The default `00_acme-challenge` fragment registers a default HTTP server with nginx that only allows HTTP requests to the `.well-know/acme-challenge` path to go through, while all others are redirected with a HTTP 301 status code to the equivalent `https://` URL.

It can be enabled by removing the `default` fragment in `/etc/nginx/sites-enabled` (which would otherwise conflict due to its `default_server` directive) and symlinking the `/etc/nginx/sites-available/00_acme-challenge` file into `/etc/nginx/sites-enabled`.


Scheduling coyote
-----------------

`coyote` is not a daemon, but a script that checks if work is to be done and exits otherwise. For this reason it relies on an external scheduling mechanism like cron, systemd or an admin that runs it manually.

### Using systemd

The debian package ships with systemd unit- and timer files. The unit file itself can be used to run the script once. Note that these files are template files; simply substituting a domain will run coyote correctly, although only once:

```
# systemctl start coyote@mydomain.example.com.service
```

Coyote does not require any configuration files.

While starting the the service will result in a single run, the timer can be used to automatically run coyote every day at 3 am:

```
# systemctl start coyote@mydomain.example.com.timer
```

To make the timer persist after rebooting, it should also be enabled, causing it to be started on bootup:

```
# systemctl enable coyote@mydomain.example.com.timer
```

Coyote is safe to start multiple times per day; it will only request a new certificate if the old one is about to expire.


### Multiple domains

All files touched by coyote contain the domain name to be renewed. Any number of coyote instances can be run in parallel. If a server requires three domains, simply enabling/starting the respective systemd services, each with a different domain name, is enough to obtain certificates for all three.


Security
--------

`coyote` has three dependencies: [acme-tiny](https://github.com/diafygi/acme-tiny), [requests](docs.python-requests.org/) and OpenSSL. `acme-tiny` is meant to be reviewed personally, though it is also installable as a Debian packages called [acme-tiny](https://packages.debian.org/search?keywords=acme-tiny). `requests` can be installed on Debian in the form of [python3-requests](https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=python3-requests). Alternatively it can also be installed "manually"using virtualenv.

Since `coyote` is a single file executable, it can and should also be reviewed manually, similar to `acme-tiny`.

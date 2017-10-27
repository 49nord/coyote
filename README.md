coyote: Automatic let's encrypt / ACME certificate renewal
==========================================================


Security
--------

`coyote` has two dependencies: [`acme-tiny`](https://github.com/diafygi/acme-tiny) and [requests](docs.python-requests.org/). `acme-tiny` is meant to be reviewed personally, though it is also installable as a Debian packages called [`acme-tiny`](https://packages.debian.org/search?keywords=acme-tiny). `requests` can be installed on Debian in the form of [`python3-requests`](https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=python3-requests). Alternatively it can also be installed "manually" using virtualenv.

Since `coyote` is a single file executable, it can and should also be reviewed manually, similar to `acme-tiny`.

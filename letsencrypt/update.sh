#!/bin/sh

/usr/bin/certbot certonly \
    --standalone \
    --email info@license.by \
    --renew-by-default \
    --rsa-key-size 4096 \
    -d license.by \
    -d www.license.by \
    -d agpl.license.by \
    -d apache.license.by \
    -d bsd.license.by \
    -d fdl.license.by \
    -d gpl.license.by \
    -d lgpl.license.by \
    -d mit.license.by \
    -d mpl.license.by \
    --pre-hook 'systemctl stop nginx' \
    --post-hook 'systemctl start nginx'

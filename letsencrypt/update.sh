#!/bin/sh

/home/license/letsencrypt/certbot/certbot-auto certonly --standalone --email info@hackerspace.by --renew-by-default --rsa-key-size 4096 -d license.by -d www.license.by -d agpl.license.by -d apache.license.by -d bsd.license.by -d cc-by-sa.license.by -d fdl.license.by -d gpl.license.by -d lgpl.license.by -d mit.license.by -d mpl.license.by --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"

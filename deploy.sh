#!/bin/sh

LICENSE_USER='license'
LICENSE_DIR="/home/$LICENSE_USER"
LICENSE_TMP_DIR="$LICENSE_DIR/tmp"

SITE_BRANCH='master'
SITE_DIR="$LICENSE_DIR/site"
SITE_URL="https://codeload.github.com/license-by/site/tar.gz/$SITE_BRANCH"

DEPLOY_BRANCH='master'
DEPLOY_URL="https://codeload.github.com/license-by/deploy/tar.gz/$DEPLOY_BRANCH"

#NGINX_APT_FILE='/etc/apt/sources.list.d/nginx.list'
NGINX_ETC_DIR='/etc/nginx'
NGINX_DIR="$LICENSE_DIR/nginx"
NGINX_LOGS_DIR="$NGINX_DIR/logs"
NGINX_CONFIGS_DIR="$NGINX_DIR/configs"

LETSENCRYPT_DIR="$LICENSE_DIR/letsencrypt"
LETSENCRYPT_BRANCH='master'
LETSENCRYPT_URL="https://codeload.github.com/certbot/certbot/tar.gz/$LETSENCRYPT_BRANCH"

SSL_DIR="$LICENSE_DIR/ssl"
SSL_TICKET_KEY_FILE="$SSL_DIR/ticket.key"
SSL_TICKET_KEY_BIT_SIZE=80
SSL_DHPARAM_FILE="$SSL_DIR/dhparam.pem"
SSL_DHPARAM_BIT_SIZE=4096


# Structure create
structure_define()
{
    echo "Structure building..."

    mkdir -p "$LICENSE_TMP_DIR" && \
    mkdir -p "$SITE_DIR" && \
    mkdir -p "$SSL_DIR" && \
    mkdir -p "$NGINX_DIR" && \
    mkdir -p "$LETSENCRYPT_DIR"
}

# Structure remove
structure_remove()
{
    rm -rf "$LICENSE_TMP_DIR" && \
    rm -rf "$SITE_DIR" && \
    rm -rf "$SSL_DIR" && \
    rm -rf "$NGINX_DIR" && \
    rm -rf "$LETSENCRYPT_DIR" && \
    rm -rf "$LICENSE_LOGS_DIR"
}

# Deploy download
deploy_download()
{
    echo "Deploy source downloading..."

    cd "$LICENSE_TMP_DIR" && curl -SL "$DEPLOY_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi
}

# SSL Ticket key generate
openssl_ticket_key_define()
{
    openssl rand "$SSL_TICKET_KEY_BIT_SIZE" > "$SSL_TICKET_KEY_FILE"
}

# DHParam generate
openssl_dhparam_define()
{
    openssl dhparam -out "$SSL_TICKET_KEY_FILE" "$SSL_DHPARAM_BIT_SIZE"
}

# SSL
ssl_define()
{
    openssl_ticket_key_define && \
    openssl_dhparam_define
}

# NGinx
nginx_define()
{
#    sudo rm -f "$NGINX_APT_FILE" && \
#    sudo touch "$NGINX_APT_FILE" && \
#    sudo echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
#    sudo apt-get update -y && sudo apt-get install -y nginx && sudo apt-get autoclean -y

    for f in $(ls "$NGINX_CONFIGS_DIR/"); do
        echo "$f"

        sudo ln -sf "$NGINX_CONFIGS_DIR/$f" "$NGINX_ETC_DIR/conf.d" && \

        mkdir -p "$NGINX_LOGS_DIR/$(echo $f | cut -f 1 -d '.')"
    done
}

# Let's Encrypt
letsencrypt_define()
{
    echo "Let's Encrypt source downloading..."

    cd "$LETSENCRYPT_DIR" && curl -SL "$LETSENCRYPT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi

    mv "$LETSENCRYPT_DIR/certbot-$LETSENCRYPT_BRANCH" "$LETSENCRYPT_DIR/certbot"
}

# Deploy
deploy_define()
{
    local deploy_dir="$LICENSE_TMP_DIR/deploy-$DEPLOY_BRANCH/"

    mv "$deploy_dir/letsencrypt" "$LICENSE_DIR/" && \
    mv "$deploy_dir/nginx" "$LICENSE_DIR/" && \
    rm -rf "$deploy_dir/" && \

    ssl_define && \
    nginx_define && \
    letsencrypt_define
}

# Site download
site_download()
{
    echo "Site source downloading..."

    cd "$LICENSE_TMP_DIR" && curl -SL "$SITE_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some errors with deploy source downloading for '$DEPLOY_URL'"
        structure_remove

        exit 1
    fi
}

# Site
site_define()
{
    local site_dir="$LICENSE_TMP_DIR/site-$SITE_BRANCH/"

    for f in $(ls "$site_dir/"); do
        mv "$site_dir/$f" "$SITE_DIR/"
    done

    rm -rf "$site_dir/"
}

# Main
deploy()
{
    structure_remove && \
    structure_define && \

    deploy_download && \
    deploy_define && \

    site_download && \
    site_define && \

    rm -rf "$LICENSE_TMP_DIR"
}


# Run
deploy

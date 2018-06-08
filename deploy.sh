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

LETSENCRYPT_DIR="$LICENSE_DIR/letsencrypt"
LETSENCRYPT_BRANCH='master'
LETSENCRYPT_URL="https://codeload.github.com/certbot/certbot/tar.gz/$LETSENCRYPT_BRANCH"

LICENSE_DHPARAM_KEY_FILE="$LETSENCRYPT_DIR/dhparam.pem"
LICENSE_SSL_BIT_KEY_SIZE=4096


structure_define()
{
    echo "Structure building..."

    mkdir -p "$LICENSE_TMP_DIR"
    mkdir -p "$SITE_DIR"
    mkdir -p "$NGINX_DIR"
    mkdir -p "$LETSENCRYPT_DIR"
}

structure_remove()
{
    rm -rf "$LICENSE_TMP_DIR"
    rm -rf "$SITE_DIR"
    rm -rf "$NGINX_DIR"
    rm -rf "$LETSENCRYPT_DIR"
}

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

# DHParam
openssl_dhparam_define()
{
    openssl dhparam -out "$LICENSE_DHPARAM_KEY_FILE" "$LICENSE_SSL_BIT_KEY_SIZE"
}

nginx_define()
{
#    sudo rm -f "$NGINX_APT_FILE" && \
#    sudo touch "$NGINX_APT_FILE" && \
#    sudo echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> "$NGINX_APT_FILE" && \
#    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
#    sudo apt-get update -y && sudo apt-get install -y nginx && sudo apt-get autoclean -y

    for f in $(ls "$NGINX_DIR/"); do
        echo "$f"
        sudo ln -sf "$NGINX_DIR/$f" "$NGINX_ETC_DIR/conf.d"
    done

    openssl_dhparam_define
}

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

deploy_define()
{
    local deploy_dir="$LICENSE_TMP_DIR/deploy-$DEPLOY_BRANCH/"

    mv "$deploy_dir/letsencrypt" "$LICENSE_DIR/"
    mv "$deploy_dir/nginx" "$LICENSE_DIR/"
    rm -rf "$deploy_dir/"

    nginx_define
    letsencrypt_define
}

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

site_define()
{
    local site_dir="$LICENSE_TMP_DIR/site-$SITE_BRANCH/"

    for f in $(ls "$site_dir/"); do
        mv "$site_dir/$f" "$SITE_DIR/"
    done

    rm -rf "$site_dir/"
}

deploy()
{
    structure_remove
    structure_define

    deploy_download
    deploy_define

    site_download
    site_define

    rm -rf "$LICENSE_TMP_DIR"
}


deploy

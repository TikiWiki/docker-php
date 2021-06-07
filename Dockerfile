FROM php:7-fpm

LABEL mantainer "TikiWiki <tikiwiki-devel@lists.sourceforge.net>"
LABEL PHP_VERSION=7.4.20

RUN apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libldb-dev \
        libmemcached-dev \
        libonig-dev \
        libpng++-dev \
        libzip-dev \
        unzip \
        zlib1g-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install bcmath calendar gd intl ldap mysqli mbstring pdo_mysql zip \
    && printf "yes\n" | pecl install xdebug-2.9.8 \
    && printf "no\n"  | pecl install apcu-beta \
    && printf "no\n"  | pecl install memcached \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/pecl-apcu.ini \
    && echo 'extension=memcached.so' > /usr/local/etc/php/conf.d/pecl-memcached.ini \
    && echo "extension=ldap.so" > /usr/local/etc/php/conf.d/docker-php-ext-ldap.ini \
    && apt-get purge -y \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libldb-dev \
        libmemcached-dev \
        libonig-dev \
        libpng++-dev \
        libzip-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && { \
        echo "file_uploads = On"; \
        echo "upload_max_filesize = 2048M"; \
        echo "post_max_size = 2048M"; \
        echo "max_file_uploads = 20"; \
    } > /usr/local/etc/php/conf.d/docker-uploads.ini \
    && mkdir -p /var/www/.composer /var/www/.config \
    && chown www-data:www-data /var/www/.composer /var/www/.config \
    && curl -s -L -o /usr/local/bin/composer https://getcomposer.org/download/latest-1.x/composer.phar \
    && chmod 755 /usr/local/bin/composer \
    && { \
        COMPOSER_HOME=/usr/local/share/composer \
        COMPOSER_BIN_DIR=/usr/local/bin \
        COMPOSER_CACHE_DIR="/tmp/composer" \
        composer global require psy/psysh; \
    } \
    && rm -rf /tmp/*

COPY root/ /
EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

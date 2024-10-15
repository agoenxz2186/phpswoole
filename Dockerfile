FROM phpswoole/swoole:php8.3-alpine

#ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/


# make sure you can use HTTPS
RUN apk --update add ca-certificates

RUN \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer                                                                     && \
    composer self-update --clean-backups 2.8.1  && \
    apk update && \
    apk add --no-cache libstdc++


RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install uploadprogress \
    && docker-php-ext-enable uploadprogress \
    && apk del .build-deps $PHPIZE_DEPS \
    && chmod uga+x /usr/local/bin/install-php-extensions && sync \
    && install-php-extensions bcmath \
            bz2 \
            calendar \
            curl \
            exif \
            fileinfo \
            ftp \
            gd \
            gettext \
#            imagick \
            imap \
            intl \
            ldap \
            mcrypt \
            memcached \
            mongodb \
            mysqli \
            opcache \
             pdo \
            pdo_mysql \
            pgsql \
            pdo_pgsql \
            soap \
            sodium \
            sysvsem \
            sysvshm \
            zip

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev ghostscript
RUN apk add php83-pecl-imagick --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN set -eux; \
        install-php-extensions \
                Imagick/imagick@28f27044e435a2b203e32675e942eb8de620ee58 ;
 
RUN docker-php-ext-enable imagick
RUN apk add --no-cache libpng libjpeg-turbo libwebp freetype icu icu-data-full
RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd
RUN docker-php-ext-install exif 
    rm -f $HOME/.composer/*-old.phar && \
    apk del .build-deps
RUN apk add --update supervisor && rm -rf /tmp/* /var/cache/apk/*

RUN apk add poppler-utils

WORKDIR "/var/www/"

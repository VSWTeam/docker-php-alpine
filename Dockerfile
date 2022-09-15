FROM php:8.0.19-fpm-alpine3.15

RUN apk add --no-cache \
        curl \
        freetype \
        icu \
        imagemagick \
        imagemagick-libs \
        libjpeg-turbo \
        libpng \
        libwebp \
        libzip \
        mysql-client \
        rsync

RUN apk add --no-cache --virtual \
        .docker-php-imagick-dependancies \
        freetype-dev \
        icu-dev \
        icu-libs \
        imagemagick-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        make \
        zlib-dev \

    # Install extension
    && docker-php-ext-install -j$(nproc) exif intl opcache zip \
    && docker-php-ext-enable exif \
    && docker-php-ext-enable intl \

    # Install GD
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) gd \

    # Install PDO
    && docker-php-ext-install -j$(nproc) pdo_mysql \

    # Install Imagick
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
    && docker-php-ext-install imagick \
    && docker-php-ext-enable imagick \

    # Install Composer
    && curl -sS https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \

    # Clean
    && rm -rf /usr/src/php*

# Install essential build tools
RUN apk add --no-cache \
    git \
    autoconf \
    g++ \
    make \
    openssl-dev

# Install xdebug
RUN pecl install opcache xdebug \
    && echo "xdebug.mode=debug\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9000\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && docker-php-ext-enable opcache xdebug \
    && rm -rf /tmp/*

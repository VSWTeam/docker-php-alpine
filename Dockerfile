FROM php:7.4.24-fpm-alpine3.13

RUN apk add --no-cache \
        libzip-dev freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo mysql-client rsync \
  && docker-php-ext-configure gd \
    --enable-gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql opcache zip \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev \
  && docker-php-ext-install bcmath

# Install Composer
RUN apk add --no-cache curl \
  && curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar \
  && mv composer.phar /usr/local/bin/composer

# Install essential build tools
RUN apk add --no-cache \
    git \
    autoconf \
    g++ \
    make \
    openssl-dev

# Install xdebug
RUN docker-php-source extract \
    && pecl install opcache xdebug \
    && echo "xdebug.remote_enable=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && docker-php-ext-enable opcache xdebug \
    && docker-php-source delete \
    && rm -rf /tmp/*

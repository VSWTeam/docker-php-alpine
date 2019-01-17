FROM php:7.1.26-fpm-alpine3.8

RUN apk add --no-cache \
        postgresql-dev freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo mysql-client rsync \
  && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql pdo_pgsql opcache zip \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

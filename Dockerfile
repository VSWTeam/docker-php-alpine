FROM php:7.4.22-fpm-alpine3.13

RUN apk add --no-cache \
        libzip-dev freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo mysql-client rsync \
  && docker-php-ext-configure gd \
    --enable-gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql opcache zip \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# Install ImagicK
RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick-3.4.4 \
    && docker-php-ext-enable imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps

# Install DCMTK
RUN apk update \
    && apk add --no-cache libstdc++ g++ make git \
    && git clone https://github.com/DCMTK/dcmtk.git \
    && cd dcmtk \
    && git checkout DCMTK-3.6.7 \
    && cd config \
    && ./rootconf \
    && cd .. \
    && ./configure --ignore-deprecation \
    && make all \
    && make install \
    && make distclean \
    && cd .. \
    && rm -r dcmtk \
    && apk del g++ make git \
    && rm /var/cache/apk/*

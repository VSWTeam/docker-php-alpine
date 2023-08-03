FROM php:8.0.29-fpm-alpine3.16

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

# Dependency of PHP client for Google Analytics Data libraray
RUN docker-php-ext-install bcmath

# Install Composer
RUN apk add --no-cache curl \
  && curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar \
  && mv composer.phar /usr/local/bin/composer

# Install tesseract ocr
# RUN apk add tesseract-ocr
RUN set -xe \
    && apk add --no-cache \
        tesseract-ocr \
        tesseract-ocr-data-chi_sim \
        tesseract-ocr-data-chi_tra \
        tesseract-ocr-data-jpn \
        tesseract-ocr-data-kor

FROM php:8.0.17-fpm-alpine3.15

RUN apk add --no-cache ${PHPIZE_DEPS} \
        libzip-dev freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo \
        mysql-client \
        rsync \
    && docker-php-ext-configure gd \
      --enable-gd \
      --with-freetype=/usr/include/ \
      --with-jpeg=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd pdo pdo_mysql opcache zip \
    # Install imagick
    && apk add --no-cache  $PHPIZE_DEPS --virtual .imagick-deps imagemagick imagemagick-dev libgomp \
    && pecl install imagick-3.7.0 \
    && docker-php-ext-enable imagick \
    # Install Composer
    && apk add --no-cache ${PHPIZE_DEPS} curl \
    && curl -sS https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    # Clean
    && apk del --no-cache ${PHPIZE_DEPS} freetype-dev libpng-dev libjpeg-turbo-dev imagemagick-dev

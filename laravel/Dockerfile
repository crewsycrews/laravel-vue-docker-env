FROM php:7.4.3-fpm
ENV APP_ENV=prod
ENV UNAME=ubuntu
ENV UID=1000
ENV GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN usermod -a -G www-data $UNAME
RUN set -ex \
    && apt-get clean && apt-get update \
    && apt-get install -my wget gnupg \
    && apt-get install -q -y --no-install-recommends \
        zlib1g-dev \
        libpng-dev \
        libjpeg-dev \
        libonig-dev \
        libzip-dev \
        unzip \
        procps \
        curl \
        git \
    && git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && docker-php-ext-install redis \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install ctype \
    && docker-php-ext-install json \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install gd \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN set -ex; \
    pecl install xdebug; \
    docker-php-ext-enable xdebug; \
    touch /var/log/cron.log
RUN mkdir -p /var/www/laravel/
RUN chown -R www-data:www-data /var/www/&& chmod -R 755 /var/www/
WORKDIR /var/www/laravel
COPY --chown=www-data:www-data custom-php.ini /usr/local/etc/php/conf.d/
COPY --chown=www-data:www-data ./src/ /var/www/laravel/
USER www-data
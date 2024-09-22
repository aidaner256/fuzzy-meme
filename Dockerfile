# this dockerfile is generated from a template
# do not modify it directly, modify the template instead
# template: templates/Dockerfile.develop.j2

FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get upgrade --no-install-recommends -y && \
    apt-get install --no-install-recommends -y \
    curl \
    cron \
    zip \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libsqlite3-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure zip --with-zip && \
	docker-php-ext-configure gd --with-jpeg --with-webp && \
    docker-php-ext-install \
    exif \
    gd \
    mysqli \
    pdo \
    pdo_sqlite \
    pdo_pgsql \
    pdo_mysql \
    simplexml \
    zip \
    opcache

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/custom.ini
RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit.ini

# Recommended opcache settings - https://secure.php.net/manual/en/opcache.installation.php
RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=2'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/docker-wn-opcache.ini

RUN { \
	echo 'log_errors=on'; \
	echo 'display_errors=on'; \
	echo 'upload_max_filesize=128M'; \
	echo 'post_max_size=128M'; \
	echo 'memory_limit=128M'; \
    echo 'expose_php=off'; \
	} > /usr/local/etc/php/conf.d/docker-wn-php.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --2 --install-dir=/usr/local/bin --filename=composer

# install wintercms, set laravel env, and create database
RUN composer create-project --prefer-dist wintercms/winter . && \
    echo 'APP_ENV=docker\nDB_CONNECTION=mysql\nDB_HOST=172.19.0.2\nDB_PORT=3306\nDB_DATABASE=wintercms\nDB_USERNAME=test\nDB_PASSWORD=123' > .env 

# get laravel env config files
COPY config/docker config/docker

# install winter
#RUN php artisan migrate
#RUN php artisan winter:install
RUN composer install

# permissions
RUN chown -R www-data:www-data /var/www/html && \
    find . -type d \( -path './plugins' -or  -path './storage' -or  -path './themes' -or  -path './plugins/*' -or  -path './storage/*' -or  -path './themes/*' \) -exec chmod g+ws {} \;

# entrypoint
COPY docker-wn-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-wn-entrypoint.sh"]

# command
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
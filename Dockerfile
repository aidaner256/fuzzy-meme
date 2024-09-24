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

# Recommended opcache settings - https://secure.php.net/manual/en/opcache.installation.php
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit.ini && \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/docker-wn-opcache.ini && \
    { \
        echo 'log_errors=on'; \
        echo 'display_errors=on'; \
        echo 'upload_max_filesize=128M'; \
        echo 'post_max_size=128M'; \
        echo 'memory_limit=128M'; \
        echo 'expose_php=off'; \
    } > /usr/local/etc/php/conf.d/docker-wn-php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --2 --install-dir=/usr/local/bin --filename=composer

# Install WinterCMS. 
RUN composer create-project --prefer-dist wintercms/winter . 
# Set Laravel env, and create database
RUN echo 'APP_ENV=docker\nDB_CONNECTION=mysql\nDB_HOST=host.docker.internal\nDB_PORT=3307\nDB_DATABASE=test\nDB_USERNAME=test\nDB_PASSWORD=123' > .env 

# Get Laravel env config files
COPY config/docker config/docker
RUN php artisan migrate
# Install dependencies
RUN composer install

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    find . -type d \( -path './plugins' -or -path './storage' -or -path './themes' -or -path './plugins/*' -or -path './storage/*' -or -path './themes/*' \) -exec chmod g+ws {} \;

# Copy entrypoint script and set permissions
COPY docker-wn-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-wn-entrypoint.sh

# Entry point
ENTRYPOINT ["docker-wn-entrypoint.sh"]
RUN echo 'APP_ENV=docker\nDB_CONNECTION=mysql\nDB_HOST=host.docker.internal\nDB_PORT=3307\nDB_DATABASE=test\nDB_USERNAME=test\nDB_PASSWORD=123' > /var/www/html/.env
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=8000"]
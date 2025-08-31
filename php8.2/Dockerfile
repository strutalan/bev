FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    git \
    curl \
    vim \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        zip \
        xml \
    && docker-php-ext-enable opcache

# Install Redis extension (common for WP caching)
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Imagick (optional but nice for WP media handling)
RUN apt-get install -y libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom PHP config (if you want overrides for WP)
COPY ./php.ini /usr/local/etc/php/conf.d/wp-custom.ini

WORKDIR /var/www/html

# Download and setup WordPress
RUN curl -o latest.tar.gz https://wordpress.org/latest.tar.gz \
    && tar xf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress/* . \
    && rmdir wordpress \
    && chown -R www-data:www-data /var/www/html

CMD ["php-fpm"]

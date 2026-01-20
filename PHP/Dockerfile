FROM php:8.3-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    && docker-php-ext-install zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy application files
COPY index.php .
COPY opentelemetry-init.php .

# Set proper ownership and permissions for all files including vendor
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Enable auto-prepend file for OpenTelemetry via php.ini
RUN echo "auto_prepend_file = /var/www/html/opentelemetry-init.php" >> /usr/local/etc/php/conf.d/opentelemetry.ini

EXPOSE 80

FROM php:8.4-fpm

# --- BUILD ENV VARS ---
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=22

# --- INSTALL SYSTEM DEPENDENCIES ---
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    unzip \
    zip \
    git \
    gnupg \
    ca-certificates \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    supervisor

# --- INSTALL PHP EXTENSIONS ---
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd

# --- INSTALL NODE.JS (v18 LTS) ---
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs

# --- INSTALL COMPOSER ---
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# --- SET WORKDIR & COPY FILES ---
WORKDIR /var/www
COPY . /var/www

# --- SET PERMISSIONS ---
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# --- COPY NGINX AND SUPERVISOR CONFIG ---
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- BUILD ---
RUN composer install
RUN npm ci
RUN npm run build:ssr

# --- RUNTIME ENV VARS ---
ENV INERTIA_SSR_ENABLED=true

# --- EXPOSE PORTS ---
EXPOSE 80
# EXPOSE 13714

# --- OPTIMIZE THE BUILD ---
RUN php artisan optimize

# --- START SUPERVISOR ---
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

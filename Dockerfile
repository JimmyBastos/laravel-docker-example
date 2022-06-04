#
# Build
#

FROM composer:latest as builder

WORKDIR /src/app

# Install extensions dependencies
# RUN apk --update add libzip-dev libpng-dev zlib-dev pcre-dev oniguruma-dev libmemcached-dev ${PHPIZE_DEPS}

# # Add memcached
# RUN echo | pecl upgrade memcached && docker-php-ext-enable memcached

# # Add php extensions
# RUN docker-php-ext-install \
#     mbstring \
#     pdo_mysql \
#     zip \
#     exif \
#     pcntl \
#     gd

COPY . .

RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist

RUN composer dump-autoload --optimize --classmap-authoritative

#
# Application
#

FROM php:8.1.0-fpm-alpine

WORKDIR /var/app

# Set timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy project files
COPY --from=builder /src/app/ /var/app

# Install server
RUN apk --update add nginx supervisor

# Give nginx permissions
RUN chown www-data:www-data -R /var/app

# Import settings
RUN cp .docker/supervisord.conf /etc/supervisord.conf
RUN cp .docker/php.ini /usr/local/etc/php/conf.d/app.ini
RUN cp .docker/nginx.conf /etc/nginx/http.d/default.conf

RUN chmod +x /var/app/.docker/bin/start.sh

# Clear build
# RUN apk del ${PHPIZE_DEPS}
RUN rm -rf /tmp/* /var/cache/apk/*

EXPOSE 80
ENTRYPOINT ["/var/app/.docker/bin/start.sh"]

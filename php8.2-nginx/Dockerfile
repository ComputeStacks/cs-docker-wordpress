FROM ghcr.io/computestacks/cs-docker-php:8.2-nginx

LABEL maintainer="https://computestacks.com"
LABEL org.opencontainers.image.authors="https://computestacks.com"
LABEL org.opencontainers.image.source="https://github.com/ComputeStacks/cs-docker-wordpress/tree/main/php8.2-nginx"
LABEL org.opencontainers.image.url="https://github.com/ComputeStacks/cs-docker-wordpress/tree/main/php8.2-nginx"
LABEL org.opencontainers.image.title="WordPress with PHP-FPM 8.2 and nginx"

ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
ADD https://codeload.github.com/ComputeStacks/cs-wp-plugin/tar.gz/refs/heads/main /tmp/cswp.tar.gz

COPY startup/56-cs-wp.sh /etc/my_init.d/
COPY startup/55-wordpress.sh /etc/my_init.d/
ADD conf/fpm-pool.conf /etc/php/8.2/fpm/pool.d/www.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/site.conf /etc/nginx/sites-available/default
ADD nginx/multisite-subdomain.conf /opt/nginx/multisite-subdomain.conf
ADD nginx/multisite-subdirectory.conf /opt/nginx/multisite-subdirectory.conf

RUN chmod 655 /usr/local/bin/wp \
    ; \
    chmod +x /etc/my_init.d/*.sh \
        && chmod +x /usr/local/bin/wp \
    ; \
    mkdir -p /usr/src/wordpress \
        && cd /usr/src/wordpress \
        && wp core download --allow-root \
        && chown -R www-data:www-data /usr/src/wordpress \
    ; \
    tar -xzvf /tmp/cswp.tar.gz --directory /opt \
        && mv /opt/cs-wp-plugin-main /opt/cs-wordpress-plugin-main \
        && rm -f /tmp/cswp.tar.gz \
        && chown -R www-data: /opt/cs-wordpress-plugin-main


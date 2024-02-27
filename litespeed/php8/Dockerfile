ARG php_version
FROM ghcr.io/computestacks/cs-docker-php:${php_version}-litespeed
ARG php_version

LABEL maintainer="https://computestacks.com"
LABEL org.opencontainers.image.authors="https://computestacks.com"
LABEL org.opencontainers.image.source="https://github.com/ComputeStacks/cs-docker-wordpress/tree/main/litespeed/php8"
LABEL org.opencontainers.image.url="https://github.com/ComputeStacks/cs-docker-wordpress/tree/main/litespeed/php8"
LABEL org.opencontainers.image.title="Wordpress with PHP ${php_version} and OpenLiteSpeed"

ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
ADD https://codeload.github.com/ComputeStacks/cs-wp-plugin/tar.gz/refs/heads/main /tmp/cswp.tar.gz

COPY 52-cs-wp.sh /etc/my_init.d/
COPY 51-wordpress.sh /etc/my_init.d/
COPY root/vhosts /usr/src/lsws/conf/vhosts/
COPY enable_protected.sh /usr/local/bin/enable_protected

RUN chmod 655 /usr/local/bin/wp \
    ; \
    rm /usr/src/lsws/conf/httpd_config.conf \
    ; \
    mkdir -p /usr/src/lsws/conf/vhosts/Wordpress \
        && touch /usr/src/lsws/conf/vhosts/Wordpress/htpasswd \
        && touch /usr/src/lsws/conf/vhosts/Wordpress/htgroup \
        && chmod 644 /usr/src/lsws/conf/vhosts/Wordpress/htpasswd \
        && chmod 644 /usr/src/lsws/conf/vhosts/Wordpress/htgroup \
        && chmod +x /etc/my_init.d/*.sh \
        && chown lsadm: -R /usr/src/lsws/conf/vhosts/ \
    ; \
    chmod +x /usr/local/bin/wp \
    ; \
    mkdir -p /usr/src/wordpress \
        && cd /usr/src/wordpress \
        && wp core download --allow-root \
        && chown -R www-data:www-data /usr/src/wordpress \
    ; \
    tar -xzvf /tmp/cswp.tar.gz --directory /opt \
        && mv /opt/cs-wp-plugin-main /opt/cs-wordpress-plugin-main \
        && rm -f /tmp/cswp.tar.gz \
        && chown -R www-data: /opt/cs-wordpress-plugin-main \
        && chmod +x /usr/local/bin/enable_protected

COPY root/httpd_config.conf /usr/src/lsws/conf/httpd_config.conf

VOLUME ["/var/www", "/usr/local/lsws"]

#!/bin/bash

echo >&2 "Setting CS WP Env..."

if [ -z ${CS_AUTH_KEY} ]; then
  echo >&2 "CS_AUTH_KEY not set, generating random key..."
  export CS_AUTH_KEY=$(xxd -l24 -ps /dev/urandom | xxd -r -ps | base64 | tr -d = | tr + - | tr / _)
fi

# Ensure we always have the correct auth key.
sed -i "s/env\[CS_AUTH_KEY\] = .*/env\[CS_AUTH_KEY\] = '$CS_AUTH_KEY'/g" /etc/php/8.2/fpm/pool.d/www.conf

if [ -f "/opt/cs-wordpress-plugin-main/cstacks-config.php" ]; then
  echo >&2 "Updating ComputeStacks integration with latest version..."
  sudo -u www-data mkdir -p /var/www/html/wordpress/wp-content/mu-plugins
  sudo -u www-data cp /opt/cs-wordpress-plugin-main/cstacks-config.php /var/www/html/wordpress/wp-content/mu-plugins/
  sudo -u www-data wp --path=/var/www/html/wordpress config set CS_PLUGIN_DIR /opt/cs-wordpress-plugin-main
fi

echo >&2 "Configuring wordpress cron jobs..."
sudo -u www-data wp --path=/var/www/html/wordpress config set DISABLE_WP_CRON true

if [ -f /var/www/crontab ]; then
  if grep -Fq 'wp-cron' /var/www/crontab; then
    echo "wordpress user-cron configured, skipping..."
  else
    cat << EOF >> '/var/www/crontab'

*/30 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
  fi
fi
if [ -f /etc/cron.d/myapp ]; then
  if grep -Fq 'wp-cron' /etc/cron.d/myapp; then
    echo "wordpress system-cron configured, skipping..."
  else
    cat << EOF >> '/etc/cron.d/myapp'

*/30 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
  fi
else
  cat << EOF >> '/etc/cron.d/myapp'

*/30 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
fi

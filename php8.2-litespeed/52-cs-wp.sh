#!/bin/bash

echo >&2 "Setting CS WP Env..."

if [ -z ${CS_AUTH_KEY} ]; then
  echo >&2 "CS_AUTH_KEY not set, generating random key..."
  export CS_AUTH_KEY=$(xxd -l24 -ps /dev/urandom | xxd -r -ps | base64 | tr -d = | tr + - | tr / _)
fi

# Ensure we always have the correct auth key.
sed -i "s/CS_AUTH_KEY=.*/CS_AUTH_KEY=$CS_AUTH_KEY/g" /usr/local/lsws/conf/httpd_config.conf

# if it does not exist, create it.
grep -q -e 'CS_AUTH_KEY' /usr/local/lsws/conf/httpd_config.conf || sed -i "/extprocessor lsphp/a  env                     CS_AUTH_KEY=$CS_AUTH_KEY" /usr/local/lsws/conf/httpd_config.conf

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

MAILTO=""
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

echo >&2 "Updating litespeed configuration..."

[ -f /usr/local/lsws/conf/vhosts/Wordpress/htpasswd ] || touch /usr/local/lsws/conf/vhosts/Wordpress/htpasswd
chmod 644 /usr/local/lsws/conf/vhosts/Wordpress/htpasswd
chown lsadm:lsadm /usr/local/lsws/conf/vhosts/Wordpress/htpasswd

[ -f /usr/local/lsws/conf/vhosts/Wordpress/htgroup ] || touch /usr/local/lsws/conf/vhosts/Wordpress/htgroup
chmod 644 /usr/local/lsws/conf/vhosts/Wordpress/htgroup
chown lsadm:lsadm /usr/local/lsws/conf/vhosts/Wordpress/htgroup

if grep -Fq 'errorlog' /usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf; then
  echo "wordpress errorlog configuration found, skipping..."
else
  cat << EOF >> '/usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf'

errorlog /var/www/logs/error.log {
  useServer               0
  logLevel                NOTICE
  rollingSize             10M
  keepDays                30
  compressArchive         0
}
EOF
fi 

if grep -Fq 'accesslog' /usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf; then
  echo "wordpress accesslog configuration found, skipping..."
else
  cat << EOF >> '/usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf'

accesslog /var/www/logs/access.log {
  useServer               0
  logFormat               "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"
  logHeaders              7
  rollingSize             10M
  keepDays                30
  compressArchive         0
}
EOF
fi 

if grep -Fq 'realm protected' /usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf; then
  echo "wordpress protected realm found, skipping..."
else
  cat << EOF >> '/usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf'

realm protected {
  
  userDB  {
    location              \$SERVER_ROOT/conf/vhosts/\$VH_NAME/htpasswd
  }

  groupDB  {
    location              \$SERVER_ROOT/conf/vhosts/\$VH_NAME/htgroup
  }
}
EOF
fi 

if grep -Fq 'xmlrpc' /usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf; then
  echo "wordpress xmlrpc block found, skipping..."
else
  cat << EOF >> '/usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf'

context /xmlrpc.php {
  allowBrowse             0

  accessControl  {
    deny                  0.0.0.0/0
  }

  rewrite  {

  }
  addDefaultCharset       off

  phpIniOverride  {

  }
}
EOF
fi

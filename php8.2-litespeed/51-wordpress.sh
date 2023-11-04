#!/bin/bash

mkdir -p /var/www/html/wordpress && chown www-data:www-data /var/www/html/wordpress
mkdir -p /var/www/logs && chown www-data:www-data /var/www/logs
cd /var/www/html/wordpress

wait_for_db() {
  counter=0
  echo >&2 "Connecting to database at $WORDPRESS_DB_HOST"
  while ! mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "USE mysql;" >/dev/null; do
    counter=$((counter+1))
    if [ $counter == 30 ]; then
      echo >&2 "Error: Couldn't connect to database."
      exit 1
    fi
    echo >&2 "Trying to connect to database at $WORDPRESS_DB_HOST. Attempt $counter..."
    sleep 5
  done
}

setup_db() {
  echo >&2 "Creating the database..."
  mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD --skip-column-names -e "CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;"
}

# Install plugin function installs first plugin specified, e.g. 'install_plugin litespeed'
install_plugin() {
  echo >&2 "Installing $1..."
  sudo -u www-data wp plugin install $1 --activate && echo "Plugin $1 installed and activated succesfully!" || "Installing $1 failed; check if plugin name is correctly specified"
}

if ! [ "$(ls -A)" ]; then
  echo >&2 "No files found in $PWD - installing wordpress..."
  
  # Create DB
  wait_for_db
  setup_db

  mv /usr/src/wordpress/* .
  sudo -u www-data wp config create --dbhost=$WORDPRESS_DB_HOST --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --extra-php << 'PHP'
// If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  $_SERVER['HTTPS'] = 'on';
}
define( 'FS_METHOD', 'direct' ); 
define( 'WP_MEMORY_LIMIT', '96M' );
define( 'CS_PLUGIN_DIR', '/opt/cs-wordpress-plugin-main' );
define( 'WP_AUTO_UPDATE_CORE', 'minor' );
PHP
  if [ ! -e .htaccess ]; then
    cat > .htaccess <<-'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
SetEnvIf X-Forwarded-Proto "https" HTTPS=on
EOF
      chown www-data:www-data .htaccess
    fi

  echo >&2 "Installing Wordpress..."
  sudo -u www-data wp core install --url=$WORDPRESS_URL --title="$WORDPRESS_TITLE" --admin_user=$WORDPRESS_USER --admin_password=$WORDPRESS_PASSWORD --admin_email="$WORDPRESS_EMAIL" --skip-email

  if [[ -z "$WORDPRESS_PLUGINLIST" ]]; then
    echo "Pluginlist-variable empty, skipping plugin installation."
  else
    IFS=',' read -r -a array <<< "$WORDPRESS_PLUGINLIST"
    for i in "${array[@]}"
    do
      install_plugin $i
    done
  fi

  # check if timezone-variable exists, else default to UTC
  if [[ -z "$WORDPRESS_TIMEZONE" ]]; then
    echo "Timezone not specified: defaulting to UTC"
  else
    echo >&2 "Setting timezone to $WORDPRESS_TIMEZONE..."
    sudo -u www-data wp option update timezone_string $WORDPRESS_TIMEZONE
  fi

  # check if timezone-variable exists, else default to English
  if [[ -z "$WORDPRESS_LANGUAGE" ]]; then
    echo "Language not specified: defaulting to English"
  else
    echo >&2 "Setting language to $WORDPRESS_LANGUAGE"
    sudo -u www-data wp language core install $WORDPRESS_LANGUAGE
    sudo -u www-data wp language core activate $WORDPRESS_LANGUAGE
  fi
  
  echo "Installing CS plugin"
  sudo -u www-data mkdir -p wp-content/mu-plugins
  sudo -u www-data cp /opt/cs-wordpress-plugin-main/cstacks-config.php wp-content/mu-plugins/

  echo >&2 "Restarting webserver to enable cache..."
  /usr/local/lsws/bin/lswsctrl restart
else

  echo "Setting DB Host"
  sudo -u www-data wp config set DB_HOST $WORDPRESS_DB_HOST

fi

#!/bin/bash

echo "$1:$(openssl passwd -apr1 $2)" > /usr/local/lsws/conf/vhosts/Wordpress/htpasswd && chown lsadm:nogroup /usr/local/lsws/conf/vhosts/Wordpress/htpasswd && chmod 750 /usr/local/lsws/conf/vhosts/Wordpress/htpasswd && touch /usr/local/lsws/conf/vhosts/Wordpress/.protect_enabled && sed -i '/context \/ /a realm protected' /usr/local/lsws/conf/vhosts/Wordpress/vhconf.conf

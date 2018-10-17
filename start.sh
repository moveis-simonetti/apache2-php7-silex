#!/bin/bash

if [[ $NR_ENABLED == true ]]; then
    sudo sed -i -e "s/"REPLACE_WITH_REAL_KEY"/$NR_LICENSE_KEY/g" /scripts/newrelic.ini
    sudo sed -i -e "s/PHP Application/$NR_APP_NAME/g" /scripts/newrelic.ini
    sudo cp /scripts/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini
fi

usermod -u 1000 www-data \
    && cd /var/www/html && composer install \
    && chown -R www-data:www-data /var/www/html/app/cache && chmod 777 /var/www/html/app/cache \
    && chown -R www-data:www-data /var/www/html/app/logs && chmod 777 /var/www/html/app/logs

apache2-foreground
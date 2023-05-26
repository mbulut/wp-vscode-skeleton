#!/bin/bash

set -e

SITE_TITLE="Yet another WordPress site"
SITE_LOCALE=de_DE
ADMIN_USER=admin
ADMIN_EMAIL=admin@localhost.com
ADMIN_PASS=admin

WP_DB_HOST=db
WP_DB_USER=wp_user
WP_DB_PASS=wp_pass
WP_DB_NAME=wordpress

cd /var/www/html

if [ ! -f wp-config.php ]; then

    echo "Installing WordPress and creating site"

    wp core download

    wp config create --dbhost=$WP_DB_HOST --dbname=$WP_DB_NAME --dbuser=$WP_DB_USER --dbpass=$WP_DB_PASS --skip-check
    wp core install --url="http://localhost:8080" --title="$SITE_TITLE" --admin_user=$ADMIN_USER --admin_email=$ADMIN_EMAIL --admin_password=$ADMIN_PASS --locale=$SITE_LOCALE --skip-email
    wp language core install --activate $SITE_LOCALE

    wp plugin uninstall --deactivate --all
    wp post delete --force $(wp post list --post_type='page' --format=ids)
    wp comment delete --force $(wp comment list --field=comment_ID)

    wp option update date_format "j. F Y"
    wp option update time_format "H:i"

    while IFS="" read -r p || [ -n "$p" ] && ! [[ $p == \#* ]]; do
        wp plugin install --activate $p
    done < plugins/plugins.list

    for p in $(find plugins/ -name *.zip); do
        wp plugin install --activate $p
    done

    if [ -f theme/theme.zip ]; then
        wp theme install --activate theme/theme.zip
    fi

    wp theme uninstall $(wp theme list --status=inactive --field=name)

    wp language core update
    wp language plugin update --all
fi

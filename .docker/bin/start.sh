#!/bin/sh

cd /var/app

php artisan storage:link

# php artisan migrate:fresh --seed
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

supervisord -c /etc/supervisord.conf

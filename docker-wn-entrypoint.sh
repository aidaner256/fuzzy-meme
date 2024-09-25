#!/bin/bash
set -e

# Function to wait for the database to be ready
wait_for_db() {
  until php -r "new PDO('mysql:host=mariadb;dbname=wintercms', 'winter', 'winter_password');"; do
    >&2 echo "Database is unavailable - sleeping"
    sleep 1
  done
}

# Check if the Winter CMS should be initialized
if [ "${INIT_WINTER,,}" == "true" ]; then
  echo 'Initializing Winter CMS...'
  wait_for_db # Wait for the database to be available
  php artisan winter:up
fi

exec "$@"

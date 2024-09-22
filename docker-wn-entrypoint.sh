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

# Runs all Winter CMS unit tests. Pass test filename to run a specific test.
if [ ! -z "$UNIT_TEST" ]; then
  echo -e "Winter CMS Unit Test..."
  if [ "${UNIT_TEST,,}" == "true" ]; then
    vendor/bin/phpunit
  elif [ ! -f "$UNIT_TEST" ]; then
    echo "File '$UNIT_TEST' does not exist."
  elif [ -f "$UNIT_TEST" ]; then
    echo "Running single test: $UNIT_TEST"
    vendor/bin/phpunit $UNIT_TEST
  fi
  echo "---"
fi

exec "$@"

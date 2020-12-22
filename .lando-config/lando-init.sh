#!/bin/bash

# Variables:
## Drupal installation profile 'minimal' if not overwritten parameter:
DRUPAL_INSTALL_PROFILE="${1:minimal}"

# Install Drupal.
cd $LANDO_MOUNT
if [ -d 'web' ]; then
    FIRST_RUN=0
    echo "'web' folder already exists. No installation executed (`FIRST_RUN=0`)."
else
    FIRST_RUN=1
    echo "'web' folder does not exist yet. Starting composer installation (`FIRST_RUN=1`):"
    cd /app
    echo "-- Initializing empty git repository in 'app': --"
    git init
    git add .
    git commit -am "Initial commit."
fi

# Create file dirs.
echo "-- Creating directories and symlinks (if not existing already): --"
cd /app
mkdir -p -m 777 /app/web/sites/default/files/phpunit
mkdir -p -m 777 /app/web/sites/simpletest
mkdir -p -m 777 /app/files/private
mkdir -p -m 777 /app/files/sync
mkdir -p -m 777 /app/tmp
mkdir -p -m 777 /app/log

if [ $FIRST_RUN ]; then
    cd /app

    # Run composer install based on composer.json in the app directory:
    echo "-- Running composer installation (`composer install  --no-scripts`): --"
    # Install without scripts to prevent problems with composer-lock-diff on install:
    composer install --no-scripts

    echo "-- Committing composer install results to git: --"
    git add .
    git diff-index --quiet HEAD || git commit -am "Composer install done."

    echo "-- Running composer update & scaffold (`composer update --with-dependencies`): --"
    # Composer UPDATE required to run scaffold!
    composer update --with-dependencies
    echo "-- Committing composer update results to git: --"
    git add .
    git diff-index --quiet HEAD || git commit -am "Composer update done."
fi

# Copy default scaffold files from assets\scaffold if not yet existing:
# if [ ! -e "/app/web/sites/default/settings.php" ]; then
#     cp /app/.lando-config/scaffold/default/sites.default.settings.php /app/web/sites/default/settings.php
# fi
# if [ ! -e "/app/web/sites/default/services.yml" ]; then
#     cp /app/.lando-config/scaffold/default/sites.default.services.yml /app/web/sites/default/services.yml
# fi
# if [ ! -e "/app/web/sites/default/__settings.DEVELOPMENT.php" ]; then
#     cp /app/.lando-config/scaffold/default/sites.default.__settings.DEVELOPMENT.php /app/web/sites/default/__settings.DEVELOPMENT.php
# fi
# if [ ! -e "/app/web/sites/default/__services.DEVELOPMENT.yml" ]; then
#     cp /app/.lando-config/scaffold/default/sites.default.__services.DEVELOPMENT.yml /app/web/sites/default/__services.DEVELOPMENT.yml
# fi
# if [ ! -L "/app/files/public" ]; then
#     ln -s /app/web/sites/default/files /app/files/public
# fi
# if [ ! -L "files/simpletest" ]; then
#     ln -s /app/web/sites/simpletest /app/files/simpletest
# fi

if [ $FIRST_RUN ]; then
    echo "-- Installing Drupal site with installation profile: $DRUPAL_INSTALL_PROFILE --"
    echo "-- !! Default admin credentials: 'admin' / 'admin' !! --"
    cd /app/web
    echo drush site-install $DRUPAL_INSTALL_PROFILE -y --root=/app/web --uri=http://$LANDO_APP_NAME.$LANDO_DOMAIN --account-name=admin --account-pass=admin --site-name=lando-drupal8-test-debugging
    drush site-install $DRUPAL_INSTALL_PROFILE -y --root=/app/web --uri=http://$LANDO_APP_NAME.$LANDO_DOMAIN --account-name=admin --account-pass=admin --site-name=lando-drupal8-test-debugging
    cd /app/
fi

# Create phpunit.xml and configure.
if [ ! -f /app/web/core/phpunit.xml ]; then
    echo '-- Creating phpunit.xml. --'
    cd /app/web/core
    cp phpunit.xml.dist phpunit.xml
    sed -i 's/SIMPLETEST_DB" value=""/SIMPLETEST_DB" value="sqlite:\/\/localhost\/\/app\/web\/sites\/default\/files\/test.sqlite"/' phpunit.xml
    sed -i 's/SIMPLETEST_BASE_URL" value=""/SIMPLETEST_BASE_URL" value="http:\/\/\'$LANDO_APP_NAME'.'$LANDO_DOMAIN'"/' phpunit.xml
    sed -i 's/BROWSERTEST_OUTPUT_DIRECTORY" value=""/BROWSERTEST_OUTPUT_DIRECTORY" value="\/app\/web\/sites\/default\/files\/phpunit"/' phpunit.xml
    sed -i 's/beStrictAboutOutputDuringTests="true"/beStrictAboutOutputDuringTests="false" verbose="true"/' phpunit.xml
    sed -i 's/<\/phpunit>/<logging><log type="testdox-text" target="\/app\/web\/sites\/default\/files\/testdox.txt"\/><\/logging><\/phpunit>/' phpunit.xml
fi

echo "-- Final lando-init.sh git add & commit: --"
git add .
git diff-index --quiet HEAD || git commit -am "After init.sh - ready now!"

# Exit successfully to let follow-up commands run:
echo "-- FINISHED lando-init.sh --"
exit 0

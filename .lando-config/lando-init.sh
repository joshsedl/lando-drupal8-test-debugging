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
    echo "!!!!! Removing the .git repository from the directory to intialize a fresh one for the project itself. !!!!!"
    rm -rf .git
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
    composer install --no-scripts --ansi

    echo "-- Committing composer install results to git: --"
    git add .
    git diff-index --quiet HEAD || git commit -am "Composer install done."

    echo "-- Running composer update & scaffold (`composer update --with-dependencies`): --"
    # Composer UPDATE required to run scaffold!
    composer update --with-dependencies --ansi
    echo "-- Committing composer update results to git: --"
    git add .
    git diff-index --quiet HEAD || git commit -am "Composer update done."
fi

# Copy default scaffold files from assets\scaffold if not yet existing:
if [ ! -e "/app/web/sites/default/settings.local.php" ]; then
    # Append local.settings.php recognition to settings.php
    cd /app/web/sites/default
    cp default.settings.php settings.php
    chmod 0644 settings.php
    echo "// Added by LANDO App: $LANDO_APP_NAME" >> settings.php
    echo "if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {" >> settings.php
    echo "  include \$app_root . '/' . \$site_path . '/settings.local.php';" >> settings.php
    echo "}" >> settings.php
    chmod 0444 settings.php
    cd /app
    # Copy our settings.local.php scaffold file over:
    cp /app/.lando-config/scaffold/default/settings.local.php /app/web/sites/default/settings.local.php
fi
if [ ! -e "/app/web/sites/default/services.local.yml" ]; then
# Copy our services.local.yml scaffold file over:
    cp /app/.lando-config/scaffold/default/services.local.yml /app/web/sites/default/services.local.yml
fi
# TODO: DO WE NEED THIS?? >>
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
    drush site-install $DRUPAL_INSTALL_PROFILE -y --root=/app/web --uri=http://$LANDO_APP_NAME.$LANDO_DOMAIN --account-name=admin --account-pass=admin --site-name=$LANDO_APP_NAME --ansi
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

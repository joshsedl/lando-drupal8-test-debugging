#!/bin/bash

# Install Drupal.
cd $LANDO_MOUNT
if [ -d 'web' ]; then
    FIRST_RUN=0
    echo "Web folder already exists. No git install executed."
else
    FIRST_RUN=1
    echo "Removing my own git repository ('lando-drupal8-test-debugging') to use it for the application instead."
    cd /app
    rm -rf .git
    echo "Intializing empty git repository"
    git init
    git add .
    git commit -am "Initial commit."
fi

#if [ $FIRST_RUN ]; then
    # Upgrade PHPUnit to work with PHP 7, add drush, console, selenium
    # composer require -W "phpunit/phpunit ^6.0" "drush/drush" "drupal/console" "joomla-projects/selenium-server-standalone"
#fi

# Create file dirs.
echo "Creating dirs and symlinks."
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
    echo "Running composer install."
    # Install without scripts to prevent problems with composer-lock-diff on install:
    composer install --no-scripts
    echo "Committing changes to git."
    git add .
    git commit -am "After composer install"
    echo "Running composer update --with-dependencies."
    composer update --with-dependencies
    echo "Committing changes to git."
    git add .
    git commit -am "After composer update"   
fi

# Copy the settings and symlink the file dirs.
if [ ! -e "/app/web/sites/default/settings.php" ]; then
    cp /app/config/sites.default.settings.php /app/web/sites/default/settings.php
fi
if [ ! -e "/app/web/sites/default/services.yml" ]; then
    cp /app/config/sites.default.services.yml /app/web/sites/default/services.yml
fi
if [ ! -e "/app/web/sites/default/__settings.DEVELOPMENT.php" ]; then
    cp /app/config/sites.default.__settings.DEVELOPMENT.php /app/web/sites/default/__settings.DEVELOPMENT.php
fi
if [ ! -e "/app/web/sites/default/__services.DEVELOPMENT.yml" ]; then
    cp /app/config/sites.default.__services.DEVELOPMENT.yml /app/web/sites/default/__services.DEVELOPMENT.yml
fi
if [ ! -L "/app/files/public" ]; then
    ln -s /app/web/sites/default/files /app/files/public
fi
if [ ! -L "files/simpletest" ]; then
    ln -s /app/web/sites/simpletest /app/files/simpletest
fi

if [ $FIRST_RUN ]; then
    echo "Installing default site with default credentials: "admin"/"admin""
    cd /app/web
    drush site-install -y --account-name=admin --account-pass=admin --site-name=lando-drupal8-test-debugging
    cd /app/
fi

if [ ! -f /app/web/.gitignore ]; then
    # Ignore changed core files
    echo "# Ignore core composer files:
composer.json
composer.lock
# Ignore core when managing all of a project's dependencies with Composer
# including Drupal core.
# core

# Ignore dependencies that are managed with Composer.
# Generally you should only ignore the root vendor directory. It's important
# that core/assets/vendor and any other vendor directories within contrib or
# custom module, theme, etc., are not ignored unless you purposely do so.
/vendor/

# Ignore configuration files that may contain sensitive information.
sites/*/settings*.php
sites/*/services*.yml

# Ignore paths that contain user-generated content.
sites/*/files
sites/*/private

# Ignore SimpleTest multi-site environment.
sites/simpletest
" > /app/web/.gitignore
fi

# Create phpunit.xml and configure.
if [ ! -f /app/web/core/phpunit.xml ]; then
    echo 'Creating phpunit.xml.'
    cd /app/web/core
    cp phpunit.xml.dist phpunit.xml
    sed -i 's/SIMPLETEST_DB" value=""/SIMPLETEST_DB" value="sqlite:\/\/localhost\/\/app\/web\/sites\/default\/files\/test.sqlite"/' phpunit.xml
    sed -i 's/SIMPLETEST_BASE_URL" value=""/SIMPLETEST_BASE_URL" value="http:\/\/\'$LANDO_APP_NAME'.'$LANDO_DOMAIN'"/' phpunit.xml
    sed -i 's/BROWSERTEST_OUTPUT_DIRECTORY" value=""/BROWSERTEST_OUTPUT_DIRECTORY" value="\/app\/web\/sites\/default\/files\/phpunit"/' phpunit.xml
    sed -i 's/beStrictAboutOutputDuringTests="true"/beStrictAboutOutputDuringTests="false" verbose="true"/' phpunit.xml
    sed -i 's/<\/phpunit>/<logging><log type="testdox-text" target="\/app\/web\/sites\/default\/files\/testdox.txt"\/><\/logging><\/phpunit>/' phpunit.xml
fi

git add .
git commit -am "After init.sh - ready now!"   

# !! TODO - Put into separate file!
## Project specific - put into separate file!
echo 'Installing project specific dependencies:'
#drush pm-uninstall big_pipe comment color contact help history rdf shortcut tour update
# Install required core modules:
drush en layout_builder media media_library
# Install additional helper modules:
composer require drupal/admin_toolbar drupal/devel drupal/devel_php drupal/devel_debug_log drupal/coder drupal/examples drupal/stage_file_proxy drupal/hacked
drush en admin_toolbar devel devel_php devel_debug_log examples stage_file_proxy hacked

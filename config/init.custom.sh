#!/bin/bash

cd /app

# Custom drupal installation
## Project specific - put into separate file!
echo 'Installing project specific dependencies:'
# Enable bartik default theme
drush then -y bartik
drush config-set -Y system.theme default bartik

# Enable claro admin theme
drush then -y claro
drush config-set -Y system.theme admin claro

# Install required core modules:
drush en -y automated_cron block ckeditor config contextual block_custom menu_link_content dblog field field_ui filter menu_ui node path quickedit taxonomy editor update user views views_ui text options link image file datetime

# Install contrib modules:
composer require drupal/admin_toolbar drupal/devel drupal/devel_php drupal/devel_debug_log drupal/coder drupal/examples drupal/stage_file_proxy
# Enable contrib modules:
drush en -y admin_toolbar admin_toolbar_tools admin_toolbar_search devel devel_php devel_debug_log examples stage_file_proxy hacked

git add .
git diff-index --quiet HEAD || git commit -am "After init.custom.sh"

# Exist successfully to let follow-up commands run:
exit 0

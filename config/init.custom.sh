#!/bin/bash

cd /app/web

# Custom drupal installation
## Project specific - put into separate file!
echo 'Installing project specific dependencies:'
# Enable bartik default theme
lando drush theme:enable -y bartik
lando drush config:set -y system.theme default bartik

# Enable claro admin theme
lando drush theme:enable -y claro
lando drush config:set -y system.theme admin claro

# Install required core modules:
lando drush en -y automated_cron block ckeditor config contextual block_custom menu_link_content dblog field field_ui filter menu_ui node path quickedit taxonomy editor update user views views_ui text options link image file datetime

# Install contrib modules:
lando composer require -W drupal/admin_toolbar drupal/devel drupal/devel_php drupal/devel_debug_log drupal/coder drupal/examples drupal/stage_file_proxy
# Enable contrib modules:
lando drush en -y admin_toolbar admin_toolbar_tools admin_toolbar_search devel devel_php devel_debug_log examples stage_file_proxy hacked

git add .
git diff-index --quiet HEAD || git commit -am "After init.custom.sh"

# Exist successfully to let follow-up commands run:
exit 0

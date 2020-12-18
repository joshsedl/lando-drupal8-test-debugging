#!/bin/bash

cd /app

# Custom drupal installation
## Project specific - put into separate file!
echo 'Installing project specific dependencies:'
drush pm-uninstall -y big_pipe color contact help history rdf shortcut tour update
# Install required core modules:
drush en -y layout_builder media media_library
# Install additional helper modules:
composer require drupal/admin_toolbar drupal/devel drupal/devel_php drupal/devel_debug_log drupal/coder drupal/examples drupal/stage_file_proxy drupal/hacked
drush en -y admin_toolbar admin_toolbar_tools admin_toolbar_search devel devel_php devel_debug_log examples stage_file_proxy hacked

git add .
git commit -am "After init.custom.sh"

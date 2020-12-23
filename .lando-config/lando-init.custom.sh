#!/bin/bash

## You may modify this post-installation according to your requirements here:

# Swich into /app directory
cd /app

echo "-- Installing project specific dependencies (lando-init.custom.sh): --"
echo "-- Enable 'Bartik' as default theme: --"
# Enable bartik default theme
drush theme:enable -y --root=/app/web bartik --root=/app/web
drush config:set -y --root=/app/web system.theme default bartik

echo "-- Enable 'Claro' as default admin theme: --"
# Enable claro admin theme
drush theme:enable -y --root=/app/web claro
drush config:set -y --root=/app/web system.theme admin claro

# Install required core modules
echo "-- Enable several default core modules: --":
drush en -y --root=/app/web automated_cron block block_content ckeditor config contextual datetime menu_link_content dblog field field_ui filter inline_form_errors menu_ui node path quickedit taxonomy telephone editor update user views views_ui text options link image file

# Install contrib modules:
echo "-- Require and enable several development modules: --"
composer require --dev --ansi drupal/admin_toolbar drupal/backup_migrate drupal/devel drupal/devel_php drupal/devel_debug_log drupal/coder drupal/examples drupal/stage_file_proxy
drush en -y --root=/app/web admin_toolbar admin_toolbar_tools admin_toolbar_search backup_migrate devel devel_generate devel_php devel_debug_log stage_file_proxy webprofiler

echo "-- Final lando-init.custom.sh git add & commit: --"
git add .
git diff-index --quiet HEAD || git commit -am "After init.custom.sh"

# Exit successfully to let follow-up commands run:
echo "-- FINISHED lando-init.custom.sh --"
exit 0

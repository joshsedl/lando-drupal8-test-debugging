# lando-drupal8-test-debugging with attached VS-Code container settings (Drupal 8 composer based version)

## Purpose
The purpose of this lando "recipe" is to provide an easy setup for Drupal 8 core development, with preexisting VSCode "Best Practise" Settings and Extensions for Drupal and PHP programming.

## Setup
### IMPORTANT:
!! When you execute 'lando start' for the first time, THIS cloned git repository will be deleted and replaced by your new project specific git repository !!
That is what you'll like when using this for Drupal development, but so never run a lando command if you're working with this repository itself.

### To start:
1. Make sure your software stack is installed and up to date: you need an up to date version of [lando](https://github.com/lando/lando/releases), Docker, Chrome and java.
2. Download the the repo to a new empty project directory with the Drupal 8 or Drupal 9 branch (8.x/9.x): `git clone https://github.com/JPustkuchen/lando-drupal8-test-debugging.git -b 8.x`
3. Change into the cloned directory: 'cd lando-drupal8-test-debugging' (or rename it first as in TLDR)
4. Optionally remove the .git directory (or `lando start` will do it for you!)
5. Run 'lando start' from inside the app directory.
6. Install the VS-Code Remote-Development Extension (extension name: ms-vscode-remote.vscode-remote-extensionpack)
7. Open VSCode -> Go to "View" -> Select "Command Palette" (or press F1)
8. Start the Command "Remote-Containers: Attach to running Container" and select /drupal8phpunit_appserver_1
9. After VS-Code attached to the Container, it will ask you if you would like to install recommended Extensions, press install
10. Your VS-Code has attached to your Container and you are ready to go!

#### TLDR:
##### 8.x (latest Drupal 8 (^8) stable release)
`git clone https://github.com/joshsedl/lando-drupal8-test-debugging.git -b 8.x drupal8phpunit && cd drupal8phpunit && lando start`

### Run!

You should now be able to run Drupal 8 / 9 core tests. From the command line it looks like this:
```bash
# unit test
lando phpunit "/app/web/core/modules/toolbar/tests/src/Unit/PageCache/AllowToolbarPathTest.php"
# kernel test
lando phpunit "/app/web/core/modules/field_ui/tests/src/Kernel/EntityDisplayTest.php"
# functional test
lando phpunit "/app/web/core/modules/comment/tests/src/Functional/CommentAnonymousTest.php"
# functional javascript test
sh run-selenium.sh
lando phpunit "/app/web/core/tests/Drupal/FunctionalJavascriptTests/Tests/JSWebWithWebDriverAssertTest.php"
```
NB: You need to provide the path to the test file as seen in the container, not the host.
NNB: For Functional Javascript tests you need to start the selenium server before running the test. Selenium requires that you have java installed on your host.
NNNB: Sometimes testing becomes very slow. It can help to restart docker, or even your entire machine.

The test output files can be found in various locations under the /files directory.

### The files in this package do the following:
- **.lando.yml**: The lando file that spins up the apache/php/database containers and set some defaults. Here the init.sh script is called after the containers are up.
- **.lando.local.yml**: *For modifications* Allows custom modifications to lando.yml without overwriting .lando.yml.
- **.lando-config/\***: Lando shell scripts, scaffold files & lando related documentation.
- **.lando-config/lando-init.sh**: this script (shallow) clones the Drupal git repository to the /web dir, and checks out the default branch. Then composer install runs to complete the vendor dir. It upgrades the phpunit version to work with PHP 7.1, and installs Drush, Drupal Console and Selenium. It creates dirs for file operations in /files. It links config/sites.default.settings.php into the Drupal installation so base setup is automatic. Then it runs drush site-install to setup a working installation. Lastly it configures phpunit.xml for testing.
- **.lando-config/lando-init.custom.sh**: *For modifications* Allows custom additions to lando-init.sh. Script executed after init.sh to allow additional initializing steps, for example. By default enables typical modules & themes.
- **.lando-config/lando-linux-hosts.sh**: The hostname host.docker.internal resolves to the host machine from a container in Docker for Mac and Windows, but not Linux. This script adds this name to the hosts file.
- **.lando-config/scaffold/settings.local.php**: Scaffold settings file with local development defaults for Drupal 8.
- **.lando-config/scaffold/settings.local.yml**: settings.yml with local development settings for Drupal 8 Services.
- **assets/\***: See composer.json file which imports these assets.
- **.vscode/\***: Configuration for VSCode XDebug and PhpUnit.
- **run-selenium.sh**: this script sets the correct Chrome drive path and launches the project-local standalone Selenium server.

*Dynamically created*:
- **/web/\***: Drupal webroot created on first lando start  (see `.lando.yml`)
- **/tmp/\***: Drupal temporary files outside the webroot (see `settings.local.php`)
- **/files/\***: (Private) Drupal files outsite the webroot (see `settings.local.php`)
- **/files/sync/\***: Drupal configuration sync directory (see `settings.local.php`)

## Future improvements
- run functional and fjs tests via PHPStorm GUI
- export and import PHPStorm settings
- enable Test module by default
- use Chromedriver without Selenium
- cater for different ports if 80 is taken (in SIMPLETEST_BASE_URL)


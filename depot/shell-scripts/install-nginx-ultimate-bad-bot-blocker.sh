#!/bin/bash
set -e

# Installs the NGINX configuration for blocking bad bots
# See https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker

BINDIR=/usr/local/sbin

wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O $BINDIR/install-ngxblocker
chmod +x $BINDIR/install-ngxblocker
cd $BINDIR
./install-ngxblocker -x
chmod +x $BINDIR/setup-ngxblocker
chmod +x $BINDIR/update-ngxblocker

# -z = no configuration of vhosts. We do that ourself.
./setup-ngxblocker -x -z

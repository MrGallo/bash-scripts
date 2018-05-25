#!/bin/bash

# 1. Save to downloads folder and run it from there.
# sudo sh install-linux.sh
# 2. After linux installs, you have to enter the username and password (twice).
# enter `robuntu` for username and `robuntu` for password.

DIST="xenial"
PROVISION_FILE="provision.sh"

# install xenial image
# duration: 10 min
curl -O https://raw.githubusercontent.com/dnschneid/crouton/master/installer/crouton
sudo sh crouton -r "$DIST" -t xfce,touch,extension

sudo sh -e crouton -r "$DIST" -t keyboard -u

# run provision.sh in chroot 
# duration 16 min
curl -O https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$PROVISION_FILE
cat "$PROVISION_FILE" | sudo enter-chroot



#!/bin/bash

DIST="xenial"
PROVISION_FILE="provision-test.sh"

# install xenial image
# duration: 10 min
curl -O https://goo.gl/fd3zc
sudo sh crouton -r "$DIST" -t xfce,touch,extension

# run provision.sh in chroot 
# TODO: (download file from github)
# cat provision.sh | sudo enter-chroot
curl -O https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$PROVISION_FILE
cat "$PROVISION_FILE" | sudo enter-chroot



#!/bin/bash

DIST="xenial"
PROVISION_FILE="provision-test.sh"

# install xenial image
# duration: 10 min
echo "robuntu
robuntu
robuntu" | sudo sh ~/Downloads/crouton -r "$DIST" -t xfce,touch,extension

# run provision.sh in chroot 
# TODO: (download file from github)
# cat provision.sh | sudo enter-chroot
curl -o ~/Downloads/"$PROVISION_FILE" https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/"$PROVISION_FILE"
cat ~/Downloads/"$PROVISION_FILE" | sudo enter-chroot



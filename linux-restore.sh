#!/bin/bash
BACKUP_FILE=$(curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/image-file-name)

sudo edit-chroot -d xenial -y  # remove existing image


[ -f ./$BACKUP_FILE ] && {  # Backup file is on USB
    sudo cp ./$BACKUP_FILE ~/Downloads/
} || {  # otherwise, download it
    curl -o ~/Downloads/$BACKUP_FILE ftp://t1.218:Stro2018@10.130.12.156/$BACKUP_FILE
}

[ -f ./crouton ] && {
    sudo cp ./crouton ~/Downloads/
} || {
    curl -o ~/Downloads/crouton https://raw.githubusercontent.com/dnschneid/crouton/master/installer/crouton
}

sudo sh ~/Downloads/crouton -f ~/Downloads/$BACKUP_FILE
sudo sh ~/Downloads/crouton -u -n xenial

sudo rm -f ~/Downloads/crouton
sudo rm -f ~/Downloads/$BACKUP_FILE

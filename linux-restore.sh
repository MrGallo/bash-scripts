#!/bin/bash
BACKUP_FILE=$(curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/image-file-name)


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

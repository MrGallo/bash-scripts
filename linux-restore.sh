curl -o ~/Downloads/backup.tar.gz ftp://t1.218:Stro2018@10.130.12.156/xenial-20180925-1117.tar.gz

curl -o ~/Downloads/crouton https://raw.githubusercontent.com/dnschneid/crouton/master/installer/crouton

sudo sh ~/Downloads/crouton -f ~/Downloads/backup.tar.gz

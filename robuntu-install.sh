#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="0"
REVISION="0"
DATE="16 March 2018"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
ALIAS_FILE='~/.bash_aliases'
ARG1="$1"


install() {
    if [ ! -f $FILE_PATH$SCRIPT_NAME ]; then
        sudo wget -O "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"
        sudo echo "alias robuntu-install='bash $SCRIPT_NAME'" >> "$ALIAS_FILE"
        
        [[ SHUNIT_TRUE ]] && exit 0
        
        echo "Running locally"
        bash $FILE_PATH$SCRIPT_NAME $ARG1 $ARG2
        exit 0
    fi   
}

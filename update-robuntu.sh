#!/bin/bash

SCRIPT_NAME="$0"
ARGS="$@"
TMP_FILE="/tmp/$0"
VERSION="0"
SUBVERSION="2"
DATE="08 March 2018"
AUTHOR="Mr. Gallo"

update () {
    # download most recent version
    rm -f "$TMP_FILE"
    wget -qP /tmp "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$0" && {
        tmpFileVersion=$(head -6 $TMP_FILE | tail -1)
        tmpFileVersion="${NF_V//[^0-9]/}"
        tmpFileVersion=$((10#$NF_V))
        
        echo tmpFileVersion
        
        currentVersion="${VERSION//[^0-9]/}"
        currentVersion=$((10#currentVersion))
        
        echo currentVersion
        
        exit 0
        
        if (( NF_V > CURR_V )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            cp "$TMP_FILE" "$SCRIPT_NAME"
            rm -f "$TMP_FILE"
            
            #echo "Running updated version..."
            bash $SCRIPT_NAME $ARGS
            
            exit 0
        else
            #echo "Current version up to date."
            rm -f "$TMP_FILE"
        fi
    }
}

showHelp() {
    echo "UpdateRobuntu v$VERSION.$SUBVERSION of $DATE, by $AUTHOR."
    echo
    echo "Usage: update-robuntu"
    echo
}

main() {
    showHelp
}

update
main
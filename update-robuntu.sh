#!/bin/bash

SCRIPT_NAME="$0"
RUN_REVISION="$1"
TMP_FILE="/tmp/$0"
VERSION="0"
REVISION="4"
DATE="08 March 2018"
AUTHOR="Mr. Gallo"

update () {
    # download most recent version
    rm -f "$TMP_FILE"
    
    wget -qP /tmp "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$0" && {
        tmpFileV=$(head -6 $TMP_FILE | tail -1)
        tmpFileR=$(head -7 $TMP_FILE | tail -1)
        
        tmpFileV="${tmpFileV//[^0-9]/}"
        tmpFileV=$((10#$tmpFileV))
        
        tmpFileR="${tmpFileR//[^0-9]/}"
        tmpFileR=$((10#$tmpFileR))
        
        tmpFileVersion=$(( $tmpFileV * 1000 + $tmpFileR ))
        currentVersion=$(( $VERSION * 1000 + $REVISION ))
        
        if (( tmpFileVersion > currentVersion )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            cp "$TMP_FILE" "$SCRIPT_NAME"
            rm -f "$TMP_FILE"
            
            #echo "Running updated version..."
            bash $SCRIPT_NAME $(( $REVISION + 1))
            
            exit 0
        else
            #echo "Current version up to date."
            rm -f "$TMP_FILE"
        fi
    }
}

showHelp() {
    echo "Usage: update-robuntu"
    echo
}

main() {
    echo "UpdateRobuntu v$VERSION.$SUBVERSION of $DATE, by $AUTHOR."
    echo
    
    case "$RUN_REVISION" in
            1) echo updates-1 ;&
            2) echo updates-2 ;&
            3) echo updates-3 ;&
            4) echo updates-4 ;;
            *) showHelp && exit 0
    esac
}

update
main
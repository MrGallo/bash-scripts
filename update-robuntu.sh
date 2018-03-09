#!/bin/bash

SCRIPT_NAME="$0"
RUN_REVISION="$1"
TMP_FILE="/tmp/$0"
VERSION="1"
REVISION="1"
DATE="08 March 2018"
AUTHOR="Mr. Gallo"



main() {
    echo "UpdateRobuntu v$VERSION.$REVISION of $DATE, by $AUTHOR."
    echo
    
    case "$RUN_REVISION" in
            1) updates1 ;;           # ;& cascades
            *) noUpdates && exit 0
    esac
}

updates1() {
    echo "Installing updates..."
}

noUpdates() {
    echo "No updates."
    echo
}


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

update
main
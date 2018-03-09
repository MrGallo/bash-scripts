#!/bin/bash

SCRIPT_NAME="$0"
RUN_REVISION="$1"
TMP_FILE="/tmp/$0"
VERSION="1"
REVISION="1"
DATE="09 March 2018"
AUTHOR="Mr. Gallo"



main() {
    echo "UpdateRobuntu v$VERSION.$REVISION of $DATE, by $AUTHOR."
    echo
    
    case "$RUN_REVISION" in
            1) installTestModeScript ;;           # ;& cascades
            *) noUpdates && exit 0
    esac
}

installTestModeScript() {
    echo "Installing test-mode script into /usr/local/bin."
    echo "Adding system alias 'test-mode'."
    sudo wget -qO /usr/local/bin/ "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/test-mode.sh"
    echo "alias test-mode='bash test-mode'" >> ~/.bash_aliases
}

noUpdates() {
    echo "No updates."
    echo
}


update () {
    # download most recent version
    
    wget -qO /tmp/"$0" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$0" && {
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

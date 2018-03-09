#!/bin/bash

SCRIPT_NAME="$0"
ARGS="$@"
NEW_FILE="/tmp/$0"
VERSION="0.2.6"
DATE="March 8 2018"
AUTHOR="Mr. Gallo"


update () {
  
    # download most recent version
    rm -f "$NEW_FILE"
    wget -qP /tmp "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$0" && {
        NF_V=$(head -6 $NEW_FILE | tail -1)
        NF_V="${NF_V//[^0-9]/}"
        NF_V=$((10#$NF_V))
        
        INT_VERSION="${VERSION//[^0-9]/}"
        INT_VERSION=$((10#$INT_VERSION))

        
        if (( NF_V > INT_VERSION )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            cp "$NEW_FILE" "$SCRIPT_NAME"
            rm -f "$NEW_FILE"
            
            #echo "Running updated version..."
            bash $SCRIPT_NAME $ARGS
            
            exit 0
        else
            #echo "Current version up to date."
            rm -f "$NEW_FILE"
        fi
    }

    
}

showHelp() {
    echo "Usage: test-mode {start|stop}"
    echo "options:"
    echo "    start  - Starts test-writing mode"
    echo "    stop   - Stops test-writing mode"
    echo
}

doStart() {
    echo starting
}

doStop() {
    echo stopping
}

main () {
    echo "TestMode v$VERSION of $DATE, by $AUTHOR."
    echo
    
    if [ ! $ARGS ]; then
        showHelp
        exit 0
    fi
    
    case "$ARGS" in
        start) doStart ;;
         stop) doStop  ;;
            *) showHelp && exit 0
    esac
    
}

update
main

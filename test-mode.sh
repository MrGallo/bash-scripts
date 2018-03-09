#!/bin/bash

SCRIPT_NAME="$0"
ARGS="$@"
NEW_FILE="/tmp/$0"
VERSION="0.2.4"
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
            echo "Newer version found."
            echo "Updating current version."
            cp "$NEW_FILE" "$SCRIPT_NAME"
            rm -f "$NEW_FILE"
            
            echo "Running updated version..."
            bash $SCRIPT_NAME $ARGS
            
            exit 0
        else
            echo "Current version up to date."
            rm -f "$NEW_FILE"
        fi
    }

    
}

main () {
    echo "TestMode v$VERSION of $DATE, by $AUTHOR."
    echo
    
    if [ ! $ARGS ]; then
        echo "Usage:"
        echo "$0 start - Starts a test session"
        echo "$0 end   - Ends a test session"
        echo
        exit 0
    else
        echo "has args"
    fi
    
}

update
main

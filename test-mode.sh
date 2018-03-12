#!/bin/bash

SCRIPT_NAME=`basename "$0"`
ARGS="$@"
NEW_FILE="/tmp/$SCRIPT_NAME"
VERSION="0.3.0"
DATE="March 9 2018"
AUTHOR="Mr. Gallo"


update () {
  
    # download most recent version
    
    wget -qO "$NEW_FILE" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$SCRIPT_NAME" && {
        NF_V=$(head -6 $NEW_FILE | tail -1)
        NF_V="${NF_V//[^0-9]/}"
        NF_V=$((10#$NF_V))
        
        INT_VERSION="${VERSION//[^0-9]/}"
        INT_VERSION=$((10#$INT_VERSION))

        
        if (( NF_V > INT_VERSION )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            cp "$NEW_FILE" "$0"
            rm -f "$NEW_FILE"
            
            #echo "Running updated version..."
            bash $0 $ARGS
            
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
    clear 
    
    sudo git add -A
    git commit -m "Pre-test save"

    #    change taskbar alpha
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-alpha -s 0
    # turn off background image
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 0
    
    # Enable Internet blocking
    sudo wget -qO /etc/chromium-browser/policies/managed/URLBlacklist.json "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/test-mode/URLBlacklist.json"
    sudo wget -qO /etc/chromium-browser/policies/managed/URLWhitelist.json "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/test-mode/URLWhitelist.json"
    
    echo "  ____  _             _           _ 
 / ___|| |_ __ _ _ __| |_ ___  __| |
 \___ \| __/ _\` | '__| __/ _ \/ _\` |
  ___) | || (_| | |  | ||  __/ (_| |
 |____/ \__\__,_|_|   \__\___|\__,_|"
}

doStop() {

    clear

    echo "Deleting all new files since the test started."
    git add -A && git stash -a && git stash drop

    #    change taskbar alpha
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-alpha -s 100
    # turn off background image
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5
    
    # Disable Internet blocking
    sudo rm -f /etc/chromium-browser/policies/managed/URLBlacklist.json
    sudo rm -f /etc/chromium-browser/policies/managed/URLWhitelist.json

    clear
    echo "
      _____                   _ 
     |  __ \                 | |
     | |  | | ___  _ __   ___| |
     | |  | |/ _ \| '_ \ / _ \ |
     | |__| | (_) | | | |  __/_|
     |_____/ \___/|_| |_|\___(_)
                              "
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

#!/bin/bash

SCRIPT_NAME=`basename "$0"`
ARGS="$@"
NEW_FILE="/tmp/$SCRIPT_NAME"
VERSION="1.0.1"
DATE="March 9 2018"
AUTHOR="Mr. Gallo"


update () {
  
    # download most recent version
    
    wget -qO "$NEW_FILE" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME" && {
        NF_V=$(head -6 $NEW_FILE | tail -1)
        NF_V="${NF_V//[^0-9]/}"
        NF_V=$((10#$NF_V))
        
        INT_VERSION="${VERSION//[^0-9]/}"
        INT_VERSION=$((10#$INT_VERSION))

        
        if (( NF_V > INT_VERSION )); then 
            #echo "Newer version found."
            echo "Updating to latest version."
            sudo cp "$NEW_FILE" "/usr/local/bin/$SCRIPT_NAME"
            rm -f "$NEW_FILE"
            
            #echo "Running updated version..."
            bash "/usr/local/bin/$SCRIPT_NAME" $ARGS
            
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
    sudo git commit -m "Pre-test save"

    #    change taskbar alpha
    sudo xfconf-query -c xfce4-panel -p /panels/panel-1/background-alpha -s 0
    # turn off background image
    sudo xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 0
    
    # Enable Internet blocking
    sudo wget -qO /etc/chromium-browser/policies/managed/URLBlacklist.json "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/test-mode/URLBlacklist.json"
    sudo wget -qO /etc/chromium-browser/policies/managed/URLWhitelist.json "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/test-mode/URLWhitelist.json"
    
    echo "  ____  _             _           _ 
 / ___|| |_ __ _ _ __| |_ ___  __| |
 \___ \| __/ _\` | '__| __/ _ \/ _\` |
  ___) | || (_| | |  | ||  __/ (_| |
 |____/ \__\__,_|_|   \__\___|\__,_|"
}

doStop() {

    clear

    echo "Deleting all new files since the test started."
    sudo git add -A && sudo git stash -a && sudo git stash drop

    #    change taskbar alpha
    sudo xfconf-query -c xfce4-panel -p /panels/panel-1/background-alpha -s 100
    # turn off background image
    sudo xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5
    
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

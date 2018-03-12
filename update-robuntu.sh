#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="1"
REVISION="9"
DATE="11 March 2018"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
LEVEL_FILE=~/.robuntu_update_level
CURRENT_LEVEL=$(head -1 $LEVEL_FILE)
ARG1="$1"
ARG2="$2"

main() {
    case "$ARG1" in
        "-set-level") set_level    ;;
        "-level")     get_level    ;;
            
        "-version")   ;&
        "-v")         get_version  ;;
                
        "-revision")  ;&
        "-r")         get_revision ;;
                
        "-h")         ;&
        "-help")      show_help    ;;
        
        "-s")         ;&
        "-specific")  update_specific ;;
    esac
    
    install
    update
    
    show_header
    
    # is there a specific update request?
    if [ ! -z ${SPECIFIC_DO+x} ]; then
        DO_LEVEL="$SPECIFIC_DO"
    else
        DO_LEVEL=$((CURRENT_LEVEL + 1))
    fi

    case "$DO_LEVEL" in
        # cascade with ;&

        1) do_update installTestModeScript_20180309  ;&           
        2) do_update fixBottomPanel_20180309         ;;
        *) echo "No updates." && exit 0
    esac
}

fixBottomPanel_20180309() {
    echo "Applying bottom panel lock and position adjustment"
    wget -qO ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/update-files/2/xfce4-panel.xml"
    
    echo "Setting desktop properties"
    wget -qO ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/update-files/2/xfce4-desktop.xml"
}

installTestModeScript_20180309() {
    echo "Installing test-mode script into /usr/local/bin."
    sudo wget -qO /usr/local/bin/test-mode.sh "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/test-mode.sh"
    
    echo "Adding system alias 'test-mode'."
    sudo echo "alias test-mode='bash test-mode.sh'" >> ~/.bash_aliases
    
    echo "Initializing git repository in home directory."
    echo "Could take a while..."
    cd ~
    git init && git add -A 
    git config --local user.name "robuntu"
    git config --local user.email "robuntu@stro.ycdsb.ca"
    git commit -m "Initial commit"
    echo "... Done!"
}

update_specific() {
    if [ "$ARG2" != "" ]; then
        SPECIFIC_DO="$ARG2"
    else
        echo "Error: Need to specify an update number."
        echo "E.g., update-robuntu -specific 3"
        exit 0
    fi
}

set_level() {
    if [ "$ARG2" != "" ]; then
        echo "Setting Update Level to $ARG2"
        echo "$ARG2" > "$LEVEL_FILE"
    else
        echo "Error: Need to specify a level to set."
        echo "E.g., update-robuntu -set-level 3"
    fi
    exit 0
}

get_level() {
    echo "Current Update Level: $CURRENT_LEVEL"
    exit 0
}

get_version() {
    echo "$VERSION"
    exit 0
}

get_revision() {
    echo "$REVISION"
    exit 0
}

show_header() {
    echo "UpdateRobuntu v$VERSION.$REVISION of $DATE, by $AUTHOR."
    echo
}

do_update () {
    $1  # run update

    # was this a specific update request?
    # if so, exit early without updating level file
    [ ! -z ${SPECIFIC_DO+x} ] && exit 0
    
    # update level file
    CURRENT_LEVEL=$(($CURRENT_LEVEL + 1))
    echo $CURRENT_LEVEL > $LEVEL_FILE   
}

show_help() {
    show_header
    
    echo "Usage: update-robuntu [-options] [args]"
    echo "options:"
    echo "    -help, -h             Help screen"
    echo "    -level                Check robuntu's current update level"
    echo "    -set-level [num]      Set the update level"
    echo "    -specific, -s [num]   Run a single, specific update"
    echo
    exit 0
}

install () {
    [ ! -f "$LEVEL_FILE" ] && echo "0" > "$LEVEL_FILE"
    if [ ! -f $FILE_PATH$SCRIPT_NAME ]; then
        sudo wget -O "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$SCRIPT_NAME"
        sudo echo "alias update-robuntu='bash $SCRIPT_NAME'" >> ~/.bash_aliases
        echo "Running locally"
        bash $FILE_PATH$SCRIPT_NAME $ARG1 $ARG2
        exit 0
    fi   
}

update () {
    # download most recent version
    
    wget -qO "$TMP_FILE" "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/$SCRIPT_NAME" && {
        v="$(bash "$TMP_FILE" -v)"
        r="$(bash "$TMP_FILE" -r)"
        tmpFileV="${v//[^0-9]/}"
        tmpFileR="${r//[^0-9]/}"
        
        tmpFileVersion=$(( $tmpFileV * 1000 + $tmpFileR ))
        currentVersion=$(( $VERSION * 1000 + $REVISION ))
        
        
        if (( tmpFileVersion > currentVersion )); then 
            #echo "Newer version found."
            echo "Updating to latest version (v$VERSION.$REVISION to v$tmpFileV.$tmpFileR)."
            sudo cp "$TMP_FILE" "$FILE_PATH$SCRIPT_NAME"
            rm -f "$TMP_FILE"
            
            # echo "Running updated version..."
            bash $FILE_PATH$SCRIPT_NAME $ARG1 $ARG2
            exit 0
        else
            #echo "Current version up to date."
            rm -f "$TMP_FILE"
        fi
    }
}


main

#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="1"
REVISION="10"
DATE="12 March 2018"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
LEVEL_FILE=~/.robuntu_update_level
CURRENT_LEVEL=$(head -1 $LEVEL_FILE)
ARG1="$1"
ARG2="$2"

main() {
    install
    update
    check_for_options
    show_header
    set_DO_LEVEL
    do_updates
}


check_for_options() {
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
        
        "-l")         ;&
        "-list")      LIST=1          ;;
    esac
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


show_header() {
    echo "UpdateRobuntu v${VERSION}r${REVISION} of $DATE, by $AUTHOR."
    echo
}


set_DO_LEVEL() {
    if in_specific_mode; then
        DO_LEVEL="$SPECIFIC_DO"
    elif in_list_mode; then
        echo "List of updates:"
        DO_LEVEL=1
    else
        DO_LEVEL=$((CURRENT_LEVEL + 1))
    fi
}

do_updates() {
    case "$DO_LEVEL" in
        # cascade with ;&

        1) do_update installTestModeScript_20180309  ;&           
        2) do_update fixBottomPanel_20180309         ;;
        *) echo "No updates." && exit 0
    esac
}


do_update () {
    $1  # run update

    # in list mode? if so, return without updating level
    in_list_mode && return
    
    # was this a specific update request or listing?
    # if so, exit early without updating level file
    in_specific_mode && exit 0
    
    # update level file
    CURRENT_LEVEL=$(($CURRENT_LEVEL + 1))
    echo $CURRENT_LEVEL > $LEVEL_FILE   
}


fixBottomPanel_20180309() {
    
    show_update_details "Set bottom panel lock and adjust position. Set desktop background properties." && return
    
    wget -qO ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/update-files/2/xfce4-panel.xml"
    wget -qO ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml "https://raw.githubusercontent.com/MrGallo/bash-scripts/master/update-files/2/xfce4-desktop.xml"
}


installTestModeScript_20180309() {
    
    show_update_details "Install and configure test-mode script." && return

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


show_update_details() {
    # if '-list' option was passed, show only descriptions, don't allow update to run.
    # the 'true' command forces a premature return of update function skipping the update scripts.
    if in_list_mode; then
        echo -n "$LIST. " 
        echo $1
        LIST=$((LIST+1))
        true
    else
        echo $1
        false
    fi
}


show_help() {
    show_header
    
    echo "Usage: update-robuntu [-options] [args]"
    echo "options:"
    echo "    -help, -h             Help screen"
    echo "    -level                Check robuntu's current update level"
    echo "    -set-level [num]      Set the update level"
    echo "    -specific, -s [num]   Run a single, specific update"
    echo "    -list, -l             Display a list of all available updates"
    echo
    exit 0
}


update_specific() {
    if exists_ARG2; then
        SPECIFIC_DO="$ARG2"
    else
        echo "Error: Need to specify an update number."
        echo "E.g., update-robuntu -specific 3"
        exit 0
    fi
}


set_level() {
    if exists_ARG2; then
        echo "$ARG2" > "$LEVEL_FILE"
        echo "Successfully set update level to $ARG2"
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
    echo "UpdateRobuntu v$VERSION"
    exit 0
}


get_revision() {
    echo "UpdateRobuntu r$REVISION"
    exit 0
}


exists_ARG2() {
    if [ "$ARG2" != "" ]; then
        true
    else
        false
    fi
}


in_specific_mode() {
    if [ ! -z ${SPECIFIC_DO+x} ]; then
        true
    else
        false
    fi
}


in_list_mode() {
    if [ ! -z ${LIST+x} ]; then
        true
    else
        false
    fi
}


main

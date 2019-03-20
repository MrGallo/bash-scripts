#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="1"
REVISION="27"
DATE="20 March 2019"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
LEVEL_FILE=~/.robuntu_update_level
ALIAS_FILE=~/.bash_aliases
ARG1="$1"
ARG2="$2"
[ -f "$LEVEL_FILE" ] && CURRENT_LEVEL=$(head -1 $LEVEL_FILE)

main() {
    check_for_options
    install
    update
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
        "-list")      get_list        ;;
    esac
}


install () {
    [ ! -f "$LEVEL_FILE" ] && echo "0" | sudo tee "$LEVEL_FILE"
    if [ ! -f $FILE_PATH$SCRIPT_NAME ]; then
        sudo wget -O "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"
        sudo echo "alias robuntu-update='sudo bash $SCRIPT_NAME'" | sudo tee -a "$ALIAS_FILE"
        echo "Running locally"
        bash $FILE_PATH$SCRIPT_NAME $ARG1 $ARG2
        exit 0
    fi   
}


update () {
    # download most recent version
    
    wget -qO "$TMP_FILE" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"  && {
        v="$(bash "$TMP_FILE" -v)"
        r="$(bash "$TMP_FILE" -r)"
        
        tmpFileV="${v//[^0-9]/}"
        tmpFileR="${r//[^0-9]/}"
        
        tmpFileVersion=$(( $tmpFileV * 1000 + $tmpFileR ))
        currentVersion=$(( $VERSION * 1000 + $REVISION ))
        
        
        if (( tmpFileVersion > currentVersion )); then 
            #echo "Newer version found."
            echo "Updating to latest version (v${VERSION}r${REVISION} to v${tmpFileV}r${tmpFileR})."
            sudo mv "$TMP_FILE" "$FILE_PATH$SCRIPT_NAME"

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
    echo "RobuntuUpdate v${VERSION}r${REVISION} of $DATE, by $AUTHOR."
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

        1) do_update installRobuntuInstall_20180317   ;&
        2) do_update appendAliasFile                  ;&
        3) do_update updatePythonArcade_20190320      ;;
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
    echo "$CURRENT_LEVEL" | sudo tee "$LEVEL_FILE"
}


appendAliasFile() {
    show_update_details "Append to .bashrc_aliases file" && return
    
    echo "alias robuntu-update='sudo bash robuntu-update.sh'" | sudo tee -a "$ALIAS_FILE"
    echo "alias robuntu-install='sudo bash robuntu-install.sh'" | sudo tee -a "$ALIAS_FILE"
    source ~/.bashrc
}

installRobuntuInstall_20180317() {
    
    show_update_details "Install robuntu-install script" && return
    
    if [ ! -f "/usr/local/bin/robuntu-install.sh" ]; then
        sudo wget -qO "/usr/local/bin/robuntu-install.sh" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/robuntu-install.sh"
        echo "alias robuntu-install='sudo bash robuntu-install.sh'" | sudo tee -a "$ALIAS_FILE"
    else
        echo "RobuntuInstall already installed"
    fi
}

updatePythonArcade_20190320() {
    show_update_details "Install robuntu-install script" && return
    
    sudo python3.7 -m pip install arcade --upgrade
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
    
    echo "Usage: robuntu-update [-options] [args]"
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
        echo "$ARG2" | sudo tee "$LEVEL_FILE"
        echo "Successfully set update level to $ARG2"
    else
        echo "Error: Need to specify a level to set."
        echo "E.g., update-robuntu -set-level 3"
    fi
    exit 0
}

get_list() {
    LIST=1
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

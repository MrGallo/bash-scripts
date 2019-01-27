#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="1.0.10"
DATE="25 January 2019"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
ALIAS_FILE=~/.bash_aliases
ARG1="$1"
ARG2="$2"
APPS=(
    "RobuntuUpdate"
)

APP_DESCRIPTIONS=(
    "Script to provide quick and easy Robuntu image updates without having to \n\tre-install the entire image on every chromebook."
)

APP_INSTALL=( 
    installRobuntuUpdate
)

installRobuntuUpdate() {
    local SCRIPT_NAME="robuntu-update.sh"
    local FILE_PATH="/usr/local/bin/"
    local LEVEL_FILE=~/.robuntu_update_level
    
    [ ! -f "$LEVEL_FILE" ] && echo "0" | sudo tee "$LEVEL_FILE"
    
    sudo wget -O "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"
    echo "alias update-robuntu='sudo bash $SCRIPT_NAME'" | sudo tee -a ~/.bash_aliases
  
}



# --------------------------------------------------------------
APP_ALREADY_INSTALLED=(
    isInstalledRobuntuUpdate
)


isInstalledRobuntuUpdate() {
    if [ -f "/usr/local/bin/robuntu-update.sh" ]; then
        true
    else
        false
    fi
}

main() {
    checkPreOptions
    install
    update
    checkOptions
}

checkPreOptions() {
    case "$ARG1" in
              "-v") ;&
        "-version") getVersion        ;;
    esac
}

checkOptions() {
    case "$ARG1" in
              "-h") ;&
           "-help") getHelp           ;;
           "-list") ;&
              "-l") getList           ;;
            "-app") ;&
              "-a") doInstall "$ARG2" ;;
                 *) getHelp           ;;
    esac
}

install() {
    if [ ! -f $FILE_PATH$SCRIPT_NAME ]; then
        sudo wget -qO "$FILE_PATH$SCRIPT_NAME" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"
        echo "alias robuntu-install='sudo bash $SCRIPT_NAME'" | sudo tee -a "$ALIAS_FILE"

        if inProduction; then
            echo "Running locally"
            runLocally
        fi
    elif ! inProduction; then
        echo "Already installed"
    fi
}


update() {
    sudo wget -qO "$TMP_FILE" "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/$SCRIPT_NAME"
    
    ! inProduction && return
    
    local tmpVersion=$(bash $TMP_FILE -v)

    isNewer "$tmpVersion" "$VERSION" && {
        echo "Updating from v$VERSION to v$tmpVersion"
        sudo mv $TMP_FILE $FILE_PATH$SCRIPT_NAME
        runLocally
    }
}

isNewer() {
    tmp=$1 #${1//[^0-9]/}
    cur=$2 #${2//[^0-9]/}
    pattern="([0-9]+)\.?"
    
    # Expand tmp version
    count=0
    while [[ $tmp =~ $pattern ]]; do 
        tmpExp["$count"]="${BASH_REMATCH[1]}"
        tmp=${tmp#*"${BASH_REMATCH[1]}"}
        count=$(( count + 1 ))
    done
    
    # Expand current version
    count=0
    while [[ $cur =~ $pattern ]]; do 
        curExp["$count"]="${BASH_REMATCH[1]}"
        cur=${cur#*"${BASH_REMATCH[1]}"}
        count=$(( count + 1 ))
    done

    # compare both
    i=0
    
    while [[ i -lt 3 ]]; do
        if [[ tmpExp[$i] -gt curExp[$i] ]]; then
            true
            return
        fi
        i=$(( i + 1 ))
    done
    
    false
}

runLocally() {
    bash $FILE_PATH$SCRIPT_NAME $ARG1 $ARG2
    exit 0
}

getVersion() {
    echo $VERSION
    exit 0
}

getHelp() {
    showHeader
    
    echo "Usage: robuntu-install [option] [arg]"
    echo "options:"
    echo "    -help, -h             Help screen"
    echo "    -version, -v          Get application version"
    echo "    -list, -l             List available software"
    echo "    -app, -a [n]          Install app number n"
    echo
    
    exit 0
}

getList() {
    showHeader
    echo "Software Listing:"
    i=0
    while [ $i -lt "${#APPS[@]}" ]; do
        echo -n "    $i. ${APPS[$i]}"
        if ${APP_ALREADY_INSTALLED[$i]}; then
            echo "    (INSTALLED)"
        else
            echo
        fi
        printf "\t${APP_DESCRIPTIONS[$i]}\n"
        echo
        i=$(( i + 1 ))
    done
    exit 0
}

showHeader() {
    echo "RobuntuInstall v${VERSION} of $DATE, by $AUTHOR."
    echo
}
    
doInstall() {
    if ifExistsAndIsValid $1; then
        if appNotAlreadyInstalled $1; then
            echo "Installing ${APPS[$1]}"
            installApp $1
            echo "Finished installing ${APPS[$1]}"
        else
            echo "${APPS[$1]} is already installed."
        fi
    else
        echo "Error. You must provide a valid argument from 0 to $(( ${#APPS[@]} - 1 ))."
    fi
}

ifExistsAndIsValid() {
    if [ "$1" != "" ] && [ "$1" -lt "${#APPS[@]}" ]; then
        true
    else
        false
    fi
}

appNotAlreadyInstalled() {
    if "${APP_ALREADY_INSTALLED[$1]}"; then
        false;
    else
        true;
    fi
}

installApp() {
    "${APP_INSTALL[$1]}"
}

inProduction() {
    if [ ! "$SHUNIT_TRUE" ]; then
        true
    else
        false
    fi
    
}

if inProduction; then
    main
fi


#!/bin/bash

SCRIPT_NAME=`basename "$0"`
VERSION="1.0.3"
DATE="17 March 2018"
AUTHOR="Mr. Gallo"

FILE_PATH="/usr/local/bin/"
TMP_FILE="/tmp/$SCRIPT_NAME"
ALIAS_FILE=~/.bash_aliases
ARG1="$1"
ARG2="$2"
APPS=(
    "TestMode"
    "Play Framework"
)

APP_DESCRIPTIONS=(
    "Locks certain inernet sites when enabled.\n\tReverts linux file state when disabled."
    "Framework for creating web apps with Java (or Scala).\n\tVisit www.playframework.com for more info."
)

APP_INSTALL=( 
    installTestMode
    installPlay 
)

installTestMode() {
    echo "Installing test-mode script into /usr/local/bin."
    sudo wget -qO /usr/local/bin/test-mode.sh "https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/test-mode.sh"
    
    echo "Adding system alias 'test-mode'."
    sudo echo "alias test-mode='bash test-mode.sh'" >> ~/.bash_aliases
    
    echo "Configuring test-mode"
    echo "Initializing git repository in home directory."
    echo "Could take a while..."
    cd ~
    git init && git add -A 
    git config --local user.name "robuntu"
    git config --local user.email "robuntu@stro.ycdsb.ca"
    git commit -m "Initial commit"
    echo "... Done!"
}

installPlay() { 
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo apt-get update
    sudo apt-get install sbt
    
    wget -qO ~/scala-plugin.zip "https://plugins.jetbrains.com/plugin/download?rel=true&updateId=44173"
    find ~ -name '.Intelli*' -exec unzip ~/scala-plugin.zip -d {}/config/plugins/ \;
    sudo rm -f ~/scala-plugin.zip
}

APP_ALREADY_INSTALLED=(
    isInstalledTestMode
    isInstalledPlay    
)

isInstalledTestMode() {
    if [ -f /usr/local/bin/test-mode.sh ]; then
        true
    else
        false
    fi
}
isInstalledPlay() { 
    if [ -d ~/.ivy2 ] && [ -d ~/.sbt ] && [ -d ~/.Intelli*/config/plugins/Scala ]; then
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
        sudo echo "alias robuntu-install='bash $SCRIPT_NAME'" >> "$ALIAS_FILE"

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


#! /bin/sh
# file: examples/test-robuntu-install.sh

setUp() {
    SCRIPT_NAME='robuntu-install.sh'
    FILE_PATH=~/
    ALIAS_FILE=~/aliases.test
    TMP_FILE=/tmp/"$SCRIPT_NAME"
    ARG1=""
    
    APPS=("app1" "app2")
    APP_DESCRIPTIONS=( "app1 description" "app2 description")
    APP_INSTALL=(install0 install1)
    install0() { echo "installed"; }
    install1() { echo "install1"; }
    APP_ALREADY_INSTALLED=( isInstalledApp1 isInstalledApp2 )
    isInstalledApp1() { false; }
    isInstalledApp2() { false; }
}



# Test Install --------------------------------

test_install_shouldNotHappenWhenFileExists() {
    install

    assertTrue "should have downloaded" "[ -r $FILE_PATH$SCRIPT_NAME ]"
    actual=$(cat "$ALIAS_FILE")
    assertEquals "alias robuntu-install='bash $SCRIPT_NAME'" "$actual"
}

test_install_shouldNotRunLocallyInTestMode() {
    actual=$(install)
    assertNotEquals "should not run locally in test mode" "Running locally" "$actual"
}

test_install_shouldNotDownloadIfAlreadyInstalled() {
    touch "$FILE_PATH$SCRIPT_NAME"
    actual=$(install)
    assertEquals "Should not download if already installed" "Already installed" "$actual"
}



# Test getVersion -----------------

test_getVersion_works() {
    VERSION='1.0.1'
    actual=$(getVersion)
    expected='1.0.1'
    assertEquals $expected $actual
}



# Test Update --------------------------------
test_update_downloadsTMP_FILE() {
    update
    assertTrue "should have downloaded temp file: $TMP_FILE" "[ -r $TMP_FILE ]"
}

test_update_doesNotReplaceOnEqualVersion() {
    VERSION='1.0.0'
    
}



# Test newer ------------------

test_isNewer_0_0_1_newerThan_0_0_0() {
    assertNewer "0.0.1" "0.0.0"
}

test_isNewer_0_0_1_notNewerThan_0_0_1() {
    assertNotNewer "0.0.1" "0.0.1"
}

test_isNewer_0_0_1_notNewerThan_0_0_2() {
    assertNotNewer "0.0.1" "0.0.2"
}

test_isNewer_0_1_0_newerThan_0_0_25() {
    assertNewer "0.1.0" "0.0.25"
}

test_isNewer_15_4_6_newerThan_14_100_345() {
    assertNewer "15.4.6" "14.100.345"
}

assertNewer() {
    isNewer "$1" "$2"
    status=$?
    assertTrue "$1 should be newer than $2" $status
}

assertNotNewer() {
    isNewer "$1" "$2"
    status=$?
    assertFalse "$1 should not be newer than $2" $status
}



# Test checkOptions  ------------
test_checkOptions_installAppShouldHaveErrorWithoutSecondArg() {
    ARG1="-a"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 5)"
    expected="Error"
    assertEquals "$expected" "$actual"
    
    ARG1="-app"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 5)"
    expected="Error"
    assertEquals "$expected" "$actual"
}

test_checkOptions_installAppShouldInstall() {
    ARG1="-a"
    ARG2="0"
    
    actual="$(checkOptions "$ARG1" "$ARG2" | head -n 1)"
    expected="Installing app1"
    assertEquals "$expected" "$actual"
}

test_checkOptions_versionOptionShowsVersion() {
    ARG1="-v"
    VERSION="1.0.0"
    actual=$(checkPreOptions)
    expected='1.0.0'
    assertEquals $expected $actual
    
    ARG1="-version"
    VERSION="1.2.3"
    actual=$(checkPreOptions)
    expected='1.2.3'
    assertEquals $expected $actual
}

test_checkOptions_helpOptionShowsHelp() {
    ARG1="-h"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
    
    ARG1="-help"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
}

test_checkOptions_listOptionListsAvailable() {
    ARG1="-l"
    
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 17)"
    expected="Software Listing:"
    assertEquals "$expected" "$actual"
    
    actual="$(checkOptions | head -n 4 | tail -n 1 | head -c 11)"
    expected="    0. app1"
    assertEquals "$expected" "$actual"
    
    actual="$(checkOptions | head -n 5 | tail -c 17)"
    expected="app1 description"
    assertEquals "$expected" "$actual"
    
    actual="$(checkOptions | head -n 7 | tail -n 1 | head -c 11)"
    expected="    1. app2"
    assertEquals "$expected" "$actual"
    
    actual="$(checkOptions | head -n 8 | tail -c 17)"
    expected="app2 description"
    assertEquals "$expected" "$actual"
}

test_CheckOptions_listDisplays() {
    ARG1="-list"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 17)"
    expected="Software Listing:"
    assertEquals "$expected" "$actual"
}

testCheckOptions_helpIsShownWhenNoArgsPassed() {
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
}



# Test getList -------------------------------------------
test_getList_displaysINSTALLEDwhenInstalled() {
    isInstalledApp1() { true; }
    
    actual="$(getList | head -n 4 | tail -n 1 | tail -c 12)"
    expected="(INSTALLED)"
    assertEquals "$expected" "$actual"
}

test_getList_doesNotDisplayInstalledWhenNotInstalled() {
    actual="$(getList | head -n 4 | tail -n 1 | tail -c 12)"
    expected="(INSTALLED)"
    assertNotEquals "$expected" "$actual"
}



# Test doInstall ------------------------------------

test_doInstallFromArray0() {
    actual="$(doInstall 0 | head -n 1)"
    expected="Installing app1"
    assertEquals "$expected" "$actual"
    
    actual="$(doInstall 0 | head -n 2 | tail -n 1)"
    expected="installed"
    assertEquals "$expected" "$actual"
    
    actual="$(doInstall 0 | tail -n 1)"
    expected="Finished installing app1"
    assertEquals "$expected" "$actual"
}

test_doInstall_fromArray1() {
    
    actual="$(doInstall 1 | head -n 1)"
    expected="Installing app2"
    assertEquals "$expected" "$actual"
    
    actual="$(doInstall 1 | head -n 2 | tail -n 1)"
    expected="install1"
    assertEquals "$expected" "$actual"
    
    actual="$(doInstall 1 | tail -n 1)"
    expected="Finished installing app2"
    assertEquals "$expected" "$actual" 

}

test_doInstallShouldNotInstallIfAppAlreadyInstalled() {
    isInstalledApp1() { true; }
    
    actual="$(doInstall 0)"
    expected="app1 is already installed."
    assertEquals "$expected" "$actual"
}



# Test app functions ---------------------------

test_isInstalledPlayIsTrueWhenInstalled() {
    mkdir ~/.IntelliJwhatever
    mkdir ~/.IntelliJwhatever/config
    mkdir ~/.IntelliJwhatever/config/plugins
    mkdir ~/.IntelliJwhatever/config/plugins/Scala
    mkdir ~/.sbt
    mkdir ~/.ivy2
    
    assertTrue "Play should be installed" isInstalledPlay
    
    rmdir ~/.IntelliJwhatever/config/plugins/Scala
    rmdir ~/.IntelliJwhatever/config/plugins/
    rmdir ~/.IntelliJwhatever/config/
    rmdir ~/.IntelliJwhatever/
    rmdir ~/.sbt
    rmdir ~/.ivy2
}

test_isInstalledPlayIsFalseWhenNotFullyInstalled() {
    mkdir ~/.sbt
    mkdir ~/.ivy2
    
    assertFalse "Play should not be installed" isInstalledPlay

    rmdir ~/.sbt
    rmdir ~/.ivy2
}

test_isInstalledRobuntuUpdateIsFalseWhenNotInstalled() {
    rm -f "/usr/local/bin/robuntu-update.sh"
    assertFalse "RobuntuUpdate should not be installed" isInstalledRobuntuUpdate
}

test_isInstalledRobuntuUpdateIsTrueWhenInstalled() {
    sudo touch /usr/local/bin/robuntu-update.sh
    assertTrue "RobuntuUpdate should be installed" isInstalledRobuntuUpdate
    sudo rm -f /usr/local/bin/robuntu-update.sh
}



# -------------------------------------------

tearDown() {
    rm -f "$FILE_PATH$SCRIPT_NAME"
    rm -f "$ALIAS_FILE"
    sudo rm -f "$TMP_FILE"
}

oneTimeSetUp() {
    # Load include to test.
    . ../robuntu-install.sh
}

# Load shUnit2.
. ./shunit2
#! /bin/sh
# file: examples/test-robuntu-install.sh

# Test Install --------------------------------
setUp() {
    SCRIPT_NAME='robuntu-install.sh'
    FILE_PATH=~/
    ALIAS_FILE=~/aliases.test
    TMP_FILE=/tmp/"$SCRIPT_NAME"
}

testInstall_shouldNotHappenWhenFileExists() {
    install

    assertTrue "should have downloaded" "[ -r $FILE_PATH$SCRIPT_NAME ]"
    actual=$(cat "$ALIAS_FILE")
    assertEquals "alias robuntu-install='bash $SCRIPT_NAME'" "$actual"
}

testInstall_shouldNotRunLocallyInTestMode() {
    actual=$(install)
    assertNotEquals "should not run locally in test mode" "Running locally" "$actual"
}

testInstall_shouldNotDownloadIfAlreadyInstalled() {
    touch "$FILE_PATH$SCRIPT_NAME"
    actual=$(install)
    assertEquals "Should not download if already installed" "Already installed" "$actual"
}

# Test getVersion -----------------

testGetVersion_works() {
    VERSION='1.0.1'
    actual=$(getVersion)
    expected='1.0.1'
    assertEquals $expected $actual
}


# Test Update --------------------------------
testUpdate_downloadsTMP_FILE() {
    update
    assertTrue "should have downloaded temp file: $TMP_FILE" "[ -r $TMP_FILE ]"
}

testUpdate_doesNotReplaceOnEqualVersion() {
    VERSION='1.0.0'
    
}

# Test newer ------------------
testNewer_0_0_1_newerThan_0_0_0() {
    isNewer "0.0.1" "0.0.0"
    status=$?
    assertTrue "0.0.1 should be newer than 0.0.0" $status
}

testNewer_0_0_1_notNewerThan_0_0_1() {
    isNewer "0.0.1" "0.0.1"
    status=$?
    assertFalse "0.0.1 should not be newer than 0.0.1" $status
}

testNewer_0_0_1_notNewerThan_0_0_2() {
    isNewer "0.0.1" "0.0.2"
    status=$?
    assertFalse "0.0.1 should not be newer than 0.0.2" $status
}

testNewer_0_1_0_newerThan_0_0_25() {
    isNewer "0.1.0" "0.0.25"
    status=$?
    assertTrue "0.1.0 should be newer than 0.0.25" $status
}

testNewer_15_4_6_newerThan_14_100_345() {
    isNewer "15.4.6" "14.100.345"
    status=$?
    assertTrue "15.4.6 should be newer than 14.100.345" $status
}

# OPTIONS tests ------------

testCheckOptions_versionOptionShowsVersion() {
    ARG1="-v"
    VERSION="1.0.0"
    actual=$(checkOptions)
    expected='1.0.0'
    assertEquals $expected $actual
    
    ARG1="-version"
    VERSION="1.2.3"
    actual=$(checkOptions)
    expected='1.2.3'
    assertEquals $expected $actual
}

testCheckOptions_helpOptionShowsHelp() {
    ARG1="-h"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
    
    ARG1="-help"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
}

test_list_displaysListWithOption() {
    ARG1="-list"
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 17)"
    expected="Software Listing:"
    assertEquals "$expected" "$actual"
}

testCheckOptions_listOptionListsAvailable() {
    ARG1="-l"
    APPS=("app1" "app2")
    APP_DESCRIPTIONS=( "app1 description" "app2 description")
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

test_list_displaysINSTALLEDwhenInstalled() {
    APPS=("app1")
    APP_ALREADY_INSTALLED=(isInstalledApp1)
    isInstalledApp1() { true; }
    
    actual="$(getList | head -n 4 | tail -n 1 | tail -c 12)"
    expected="(INSTALLED)"
    assertEquals "$expected" "$actual"
}

test_list_doesNotDisplayInstalledWhenNotInstalled() {
    APPS=("app1")
    APP_ALREADY_INSTALLED=(isInstalledApp1)
    isInstalledApp1() { false; }
    
    actual="$(getList | head -n 4 | tail -n 1 | tail -c 10)"
    expected="INSTALLED"
    assertNotEquals "$expected" "$actual"
}

testCheckOptions_helpIsShownWhenNoArgsPassed() {
    actual="$(checkOptions | head -n 3 | tail -n 1 | head -c 6)"
    expected="Usage:"
    assertEquals $expected $actual
}

test_doInstallFromArray0() {
    APPS=("app1")
    APP_INSTALL=(install0)
    install0() { echo "installed"; }
    
    APP_ALREADY_INSTALLED=(isInstalledApp1)
    isInstalledApp1() { false; }
    
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

test_doInstallShouldNotInstallIfAppAlreadyInstalled() {
    APPS=("app1")
    
    APP_ALREADY_INSTALLED=(isInstalledApp1)
    isInstalledApp1() { true; }
    
    actual="$(doInstall 0)"
    expected="app1 is already installed."
    assertEquals "$expected" "$actual"
}

test_doInstall_fromArray1() {
    APPS=("app1" "app2")
    
    APP_INSTALL=(install0, install1)
    install1() { echo "install1"; }
    
    APP_ALREADY_INSTALLED=(isInstalledApp1, isInstalledApp2)
    isInstalledApp2() { false; }
    
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

tearDown() {
    ARG1=""
    VERSION="$VERSION_BAK"
    APPS="$APPS_BAK"
    APP_INSTALL="$APP_INSTALL_BAK"
    APP_ALREADY_INSTALLED="$APP_ALREADY_INSTALLED_BAK"
    APP_DESCRIPTIONS="$APP_DESCRIPTIONS_BAK"
    
    rm -f "$FILE_PATH$SCRIPT_NAME"
    rm -f "$ALIAS_FILE"
    sudo rm -f "$TMP_FILE"
}

oneTimeSetUp() {
    # Load include to test.
    . ../robuntu-install.sh
    VERSION_BAK="$VERSION"
    APPS_BAK="$APPS"
    APP_INSTALL_BAK="$APP_INSTALL"
    APP_ALREADY_INSTALLED_BAK="$APP_ALREADY_INSTALLED"
    APP_DESCRIPTIONS_BAK="$APP_DESCRIPTIONS"
}

# Load shUnit2.
. ./shunit2
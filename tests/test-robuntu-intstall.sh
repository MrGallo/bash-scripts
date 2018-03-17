#! /bin/sh
# file: examples/test-robuntu-install.sh

# Test Install
testInstallShouldNotHappenWhenFileExists() {
    SCRIPT_NAME='robuntu-install.sh'
    FILE_PATH='~/'
    ALIAS_FILE='~/aliases.test'
    TMP_FILE="/tmp/$SCRIPT_NAME"
    
    install
    assertTrue "should have downloaded" "[ -r $FILE_PATH$SCRIPT_NAME ]"
    assertTrue "should have wrote to alias file" "[ -r $ALIAS_FILE ]"
    rm "$FILE_PATH$SCRIPT_NAME"
    rm "$ALIAS_FILE"
}

oneTimeSetUp() {
  # Load include to test.
  . ../robuntu-install.sh
}

# Load shUnit2.
. ./shunit2
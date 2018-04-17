# UNDER CONSTRUCTION
# Ubuntu 16.04 (xenial) with xfce
# Gedit 3.18.3
# Ubuntu Software Center
# Chromium Browser

# Java 8
# Python 3.6.3 (With pygame 1.9.3)
# Processing 3.3.6 (Graphics/animations/games using Java or Python)
# IntelliJ Ultimate - apply for free education licensing
# PyCharm Professional - apply for free education licensing 
# Setup details
# crouton -r xenial -t xfce,extension,touch

# (From chrome-os) sudo sh -e ~/Downloads/crouton -r xenial -t keyboard -u

# (in chroot)
# (disable mousewheel rollup)
# xfconf-query -c xfwm4 -p /general/mousewheel_rollup -s false 

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install file-roller gedit git ttf-ubuntu-font-family

sudo apt-get install software-center

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6
# download and extract pycharm pro into /opt/

# Download and extract IntelliJ into /opt/

(android)
sudo apt-get install libc6-dev-i386 lib32z1 default-jdk
# download sdk-tools from website
# extract to /opt/Android
sudo ./sdkmanager --update
sudo ./sdkmanager "platforms;android-27" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository" --verbose

# install processing

# In-image
# Update clock format %A %B %e, %Y %t %I:%M %p
# Disable screensaver
sudo software-center (add chromium, set --incognito flag)
# Pycharm and intellij
# Set licence server http://10.130.12.156:8080
# Uncheck in settings open last project
# Configure project default SDK
# add processing to java libraries


# TODO:
# Add:
# update-robuntu
# test-mode
# robuntu-install


# provision.sh commands
# out of chroot
sudo sh -e ~/Downloads/crouton -r "$DIST" -t keyboard -u

# In chroot
echo "robuntu" | sudo -S echo "Begin image provisioning"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install file-roller gedit software-center chromium-browser ttf-ubuntu-font-family

# Java 8 
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

# Python 3.6
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6

# TODO: download and extract pycharm pro to /opt
# TODO: download and extract intellij ultimate to /opt

# Android
sudo apt-get install libc6-dev-i386 lib32z1 default-jdk
# TODO: download sdk-tools from website
# TODO: extract to /opt/Android

sudo # TODO: get proper bin path/sdkmanager --update
sudo # TODO: get proper bin path/sdkmanager "platforms;android-27" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository" --verbose

# Processing
# TODO: download processing to ~
PROCESSING_VERSION="3.3.7"
wget -O ~/processing.tgz http://download.processing.org/processing-3.3.7-linux64.tgz
echo "Installing Processing.\nYou may have to enter the password"

echo "Unzipping Processing to /opt folder"
sudo tar -xzvf ~/processing.tgz -C /opt/
wait $$

sudo rm -f ~/processing.tgz

echo "Adding Processing to \$PATH"
sudo su -c "ln -s /opt/processing-$PROCESSING_VERSION/processing /usr/local/bin/processing"

echo "Creating .desktop file in applications"
sudo touch /usr/share/applications/processing.desktop
sudo echo "[Desktop Entry]
Version=$PROCESSING_VERSION
Name=Processing
Comment=Processing Rocks
Exec=processing
Icon=/opt/processing-$PROCESSING_VERSION/lib/icons/pde-256.png
Terminal=false
Type=Application
Categories=AudioVideo;Video;Graphics;" >> /usr/share/applications/processing.desktop

echo "Creating file association in Ubuntu between .PDE and .PYDE files and Processing."
echo "Creating XML file..."
sudo touch /usr/share/mime/packages/processing.xml
sudo echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
<mime-type type=\"text/x-processing\">
<comment>Proecssing PDE sketch file</comment>
<sub-class-of type=\"text/x-csrc\"/>
<glob pattern=\"*.pde\"/>
</mime-type>
</mime-info>" >> /usr/share/mime/packages/processing.xml

echo "Creating PYDE XML file..."
sudo touch /usr/share/mime/packages/processing-py.xml
sudo echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
<mime-type type=\"text/x-processing\">
<comment>Proecssing PYDE sketch file</comment>
<sub-class-of type=\"text/x-csrc\"/>
<glob pattern=\"*.pyde\"/>
</mime-type>
</mime-info>" >> /usr/share/mime/packages/processing-py.xml

echo "Updating MIME database. This might take a minute..."
sudo update-mime-database /usr/share/mime
wait $$

echo "Associating file in defaluts.list"
sudo echo "text/x-processing=processing.desktop" >> /usr/share/applications/defaults.list

# TODO: add processing to launcher

# TODO: edit gedit settings

# TODO: add chromium to launcher incognito, 

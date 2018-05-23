# Need update
SDK_TOOLS='sdk-tools-linux-3859397.zip'

#--

# provision.sh commands
# out of chroot
sudo sh -e ~/Downloads/crouton -r "$DIST" -t keyboard -u

# In chroot
echo "robuntu" | sudo -S echo "Begin image provisioning"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install file-roller gedit software-center chromium-browser ttf-ubuntu-font-family git -y


# Java 8 
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update

# Work-around until webupd8 is updated
# sudo sed -i 's|JAVA_VERSION=8u161|JAVA_VERSION=8u172|' /var/lib/dpkg/info/oracle-java8-installer.*
# sudo sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/|' /var/lib/dpkg/info/oracle-java8-installer.*
# sudo sed -i 's|SHA256SUM_TGZ="6dbc56a0e3310b69e91bb64db63a485bd7b6a8083f08e48047276380a0e2021e"|SHA256SUM_TGZ="28a00b9400b6913563553e09e8024c286b506d8523334c93ddec6c9ec7e9d346"|' /var/lib/dpkg/info/oracle-java8-installer.*
# sudo sed -i 's|J_DIR=jdk1.8.0_161|J_DIR=jdk1.8.0_172|' /var/lib/dpkg/info/oracle-java8-installer.*
# End work-around

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer


# Python 3.6
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.6
echo "alias python3='python3.6'" >> ~/.bash_aliases
echo "alias python='python3'" >> ~/.bash_aliases


# download and extract pycharm pro to /opt/PyCharm
wget https://download.jetbrains.com/python/pycharm-professional-2018.1.1.tar.gz
sudo tar -C /opt -xzf pycharm-professional-2018.1.1.tar.gz
sudo mv /opt/pycharm-2018.1.1/ /opt/PyCharm
sudo rm -rf pycharm-professional-2018.1.1.tar.gz

# download pycharm settings
PC_CONFIG_DIR=$(find ~ -maxdepth 1 -name '.PyCharm*')/config
wget -O $PC_CONFIG_DIR/pycharm.key https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/pycharm.key
wget -O $PC_CONFIG_DIR/options/ide.general.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/ide.general.xml
wget -O $PC_CONFIG_DIR/options/project.default.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/project.default.xml
wget -O $PC_CONFIG_DIR/options/py_sdk_settings.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/py_sdk_settings.xml


# Download and extract intellij ultimate to /opt/IntelliJ
wget https://download.jetbrains.com/idea/ideaIU-2018.1.1-no-jdk.tar.gz
sudo tar -C /opt -xzf ideaIU-2018.1.1-no-jdk.tar.gz
find /opt/ -maxdepth 1 -name 'idea*' -exec sudo mv "{}" /opt/IntelliJ/ \;
sudo rm -rf ideaIU-2018.1.1-no-jdk.tar.gz



# Android
sudo apt-get install -y libc6-dev-i386 lib32z1 default-jdk

wget https://dl.google.com/android/repository/$SDK_TOOLS
mkdir android
unzip $SDK_TOOLS -d android/
rm -rf $SDK_TOOLS

yes | sudo android/tools/bin/sdkmanager --update
sudo android/tools/bin/sdkmanager "platforms;android-27" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository" --verbose

# download intellij settings
IJ_CONFIG_DIR=$(find ~ -maxdepth 1 -name '.IntelliJ*')/config
wget -O $IJ_CONFIG_DIR/idea.key https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/idea.key
wget -O $IJ_CONFIG_DIR/options/ide.general.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/ide.general.xml
wget -O $IJ_CONFIG_DIR/options/project.default.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/project.default.xml
wget -O $IJ_CONFIG_DIR/options/jdk.table.xml https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/jdk.table.xml

# CONFIRMED /\___________________________/\

# Processing
PROCESSING_VERSION="3.3.7"
wget -O ~/processing.tgz http://download.processing.org/processing-$PROCESSING_VERSION-linux64.tgz
echo "Installing Processing.\nYou may have to enter the password"

echo "Unzipping Processing to /opt folder"
sudo tar -xzvf ~/processing.tgz -C /opt/
wait $$
sudo find /opt -maxdepth 1 -name 'processing*' -exec sudo mv {} /opt/processing \;
sudo rm -f ~/processing.tgz

echo "Adding Processing to \$PATH"
sudo su -c "ln -s /opt/processing/processing /usr/local/bin/processing"

echo "Creating .desktop file in applications"
sudo touch /usr/share/applications/processing.desktop
sudo echo "[Desktop Entry]
Version=$PROCESSING_VERSION
Name=Processing
Comment=Processing Rocks
Exec=processing
Icon=/opt/processing/lib/icons/pde-256.png
Terminal=false
Type=Application
Categories=AudioVideo;Video;Graphics;" >> /usr/share/applications/processing.desktop

echo "Creating file association in Ubuntu between .PDE and .PYDE files and Processing."
echo "Creating XML file..."
sudo touch /usr/share/mime/packages/processing.xml
sudo chmod 666 /usr/share/mime/packages/processing.xml
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
sudo chmod 666 /usr/share/mime/packages/processing-py.xml
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
sudo chmod 666 /usr/share/applications/defaults.list
sudo echo "text/x-processing=processing.desktop" >> /usr/share/applications/defaults.list
sudo apt-get install -y gstreamer0.10-plugins-good

# edit gedit settings
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
gsettings set org.gnome.gedit.preferences.editor bracket-matching true
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor insert-spaces true
gsettings set org.gnome.gedit.preferences.editor right-margin-position 'uint32 80'
gsettings set org.gnome.gedit.preferences.editor tabs-size 'uint32 4'
gsettings set org.gnome.gedit.preferences.editor auto-indent true
gsettings set org.gnome.gedit.preferences.editor syntax-highlighting true

# TODO: download .config/xfce files

# TODO: download background image to /usr/share/backgrounds/background1.jpg


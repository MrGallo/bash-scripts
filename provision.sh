# Need to update
INTELLIJ_DOWNLOAD_FILE='ideaIU-2018.1.3-no-jdk.tar.gz'
PYCHARM_DOWNLOAD_FILE='pycharm-professional-2018.1.3.tar.gz'
SDK_TOOLS='sdk-tools-linux-3859397.zip'
PROCESSING_VERSION="3.3.7"   # http://processing.org
#--

# provision.sh commands

installer_output() {
  echo "**********************************************"
  echo "**********************************************"
  echo "**********************************************"
  echo ""
  echo $1
  echo ""
  echo "**********************************************"
  echo "**********************************************"
  echo "**********************************************"
}

echo "robuntu" | sudo -S echo "Begin image provisioning"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install file-roller gedit software-center chromium-browser ttf-ubuntu-font-family git curl -y

installer_output "Git settings"
git config --global user.email "robuntu@stro.ycdsb.ca"
git config --global user.name "robuntu"

installer_output "Java 8"
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


installer_output "Python 3.6"
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.6
echo "alias python3='python3.6'" | sudo tee -a ~/.bash_aliases
echo "alias python='python3'" | sudo tee -a ~/.bash_aliases


installer_output "download and extract pycharm pro to /opt/PyCharm"
wget https://download.jetbrains.com/python/$PYCHARM_DOWNLOAD_FILE
sudo tar -C /opt -xzf $PYCHARM_DOWNLOAD_FILE
find /opt/ -maxdepth 1 -name 'pycharm*' -exec sudo mv "{}" /opt/PyCharm/ \;
sudo rm -rf $PYCHARM_DOWNLOAD_FILE


installer_output "download pycharm settings"

[[ $PYCHARM_DOWNLOAD_FILE =~ -([0-9]{4}.[0-9]{1}) ]] && PYCHARM_VERSION=${BASH_REMATCH[1]}
PYCHARM_FOLDER=~/.PyCharm${PYCHARM_VERSION}
mkdir $PYCHARM_FOLDER
sudo chmod -R 755 $PYCHARM_FOLDER

curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/pycharm.key --create-dirs -o $PYCHARM_FOLDER/config/pycharm.key
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/ide.general.xml --create-dirs -o $PYCHARM_FOLDER/config/options/ide.general.xml
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/project.default.xml --create-dirs -o $PYCHARM_FOLDER/config/options/project.default.xml
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/pycharm/config/options/py_sdk_settings.xml --create-dirs -o $PYCHARM_FOLDER/config/options/py_sdk_settings.xml


installer_output "Download and extract intellij ultimate to /opt/IntelliJ"
wget https://download.jetbrains.com/idea/$INTELLIJ_DOWNLOAD_FILE
sudo tar -C /opt -xzf $INTELLIJ_DOWNLOAD_FILE
find /opt/ -maxdepth 1 -name 'idea*' -exec sudo mv "{}" /opt/IntelliJ/ \;
sudo rm -rf $INTELLIJ_DOWNLOAD_FILE



installer_output "Android install"
sudo apt-get install -y libc6-dev-i386 lib32z1 default-jdk

wget https://dl.google.com/android/repository/$SDK_TOOLS
mkdir android
unzip $SDK_TOOLS -d android/
rm -rf $SDK_TOOLS

yes | sudo android/tools/bin/sdkmanager --licenses
yes | sudo android/tools/bin/sdkmanager --update
sudo android/tools/bin/sdkmanager "platforms;android-27" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository" --verbose


installer_output "download intellij settings"

[[ $INTELLIJ_DOWNLOAD_FILE =~ -([0-9]{4}.[0-9]{1}) ]] && IDEA_VERSION=${BASH_REMATCH[1]}
IDEA_FOLDER=~/.IntelliJIdea${IDEA_VERSION}
mkdir $IDEA_FOLDER
sudo chmod -R 755 $IDEA_FOLDER

curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/idea.key --create-dirs -o $IDEA_FOLDER/config/idea.key
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/ide.general.xml --create-dirs -o $IDEA_FOLDER/config/options/ide.general.xml
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/project.default.xml --create-dirs -o $IDEA_FOLDER/config/options/project.default.xml 
curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/intellij/config/options/jdk.table.xml --create-dirs -o $IDEA_FOLDER/config/options/jdk.table.xml

# Processing
installer_output "Installing Processing."
wget -O ~/processing.tgz http://download.processing.org/processing-$PROCESSING_VERSION-linux64.tgz

echo "Unzipping Processing to /opt folder"
sudo tar -xzvf ~/processing.tgz -C /opt/
wait $$
sudo find /opt -maxdepth 1 -name 'processing*' -exec sudo mv {} /opt/processing \;
sudo rm -f ~/processing.tgz

echo "Adding Processing to \$PATH"
sudo su -c "ln -s /opt/processing/processing /usr/local/bin/processing"

echo "Creating .desktop file in applications"
sudo touch /usr/share/applications/processing.desktop
echo "[Desktop Entry]
Version=$PROCESSING_VERSION
Name=Processing
Comment=Processing Rocks
Exec=processing
Icon=/opt/processing/lib/icons/pde-256.png
Terminal=false
Type=Application
Categories=AudioVideo;Video;Graphics;" | sudo tee /usr/share/applications/processing.desktop

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
</mime-info>" | sudo tee /usr/share/mime/packages/processing.xml

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
</mime-info>" | sudo tee /usr/share/mime/packages/processing-py.xml

echo "Updating MIME database. This might take a minute..."
sudo update-mime-database /usr/share/mime
wait $$

echo "Associating file in defaluts.list"
sudo chmod 666 /usr/share/applications/defaults.list
sudo echo "text/x-processing=processing.desktop" | sudo tee -a /usr/share/applications/defaults.list
sudo apt-get install -y gstreamer0.10-plugins-good

installer_output "Edit gedit settings"
dbus-launch gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
dbus-launch gsettings set org.gnome.gedit.preferences.editor bracket-matching true
dbus-launch gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
dbus-launch gsettings set org.gnome.gedit.preferences.editor insert-spaces true
dbus-launch gsettings set org.gnome.gedit.preferences.editor right-margin-position 'uint32 80'
dbus-launch gsettings set org.gnome.gedit.preferences.editor tabs-size 'uint32 4'
dbus-launch gsettings set org.gnome.gedit.preferences.editor auto-indent true
dbus-launch gsettings set org.gnome.gedit.preferences.editor syntax-highlighting true

# download .config/xfce4 files (Desktop settings and launcher)
XFCE_FILES=(
  'xfce4/panel/launcher-1/15197561291.desktop'
  'xfce4/panel/launcher-11/15197525502.desktop'
  'xfce4/panel/launcher-12/15197526083.desktop'
  'xfce4/panel/launcher-10/15197382572.desktop'
  'xfce4/panel/launcher-8/15197524891.desktop'
  'xfce4/panel/launcher-9/15197382571.desktop'
  'xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml'
  'xfce4/xfconf/xfce-perchannel-xml/xsettings.xml'
  'xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml'
  'xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml'
)

installer_output "Downloading xfce4 desktop settings and launcher"

count=0
while [ "x${XFCE_FILES[count]}" != "x" ]
do
  XFCE4_FILE=${XFCE_FILES[count]}
  sudo curl https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/desktop-config/$XFCE4_FILE --create-dirs -o  ~/.config/$XFCE4_FILE
  count=$(( $count + 1 ))
done
sudo chmod -R 755 ~/.config

installer_output "Download background image to /usr/share/backgrounds/background1.jpg"
sudo wget -O /usr/share/backgrounds/background1.jpg https://raw.githubusercontent.com/MrGallo/robuntu-admin/master/provision/desktop-config/xfce4/background1.jpg

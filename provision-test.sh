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
sudo apt-get install file-roller git curl -y

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

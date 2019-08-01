# Need to update
PYCHARM_DOWNLOAD_FILE='pycharm-professional-2018.3.3.tar.gz'
# PROCESSING_VERSION="3.4"   # http://processing.org
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

installer_output ""
#!/bin/bash -e

SCRIPT=$0

# Import utility functions
source utils.sh

sqlNodeId=$(findContainerIdByName "sql_node_1")
if [ -z "$sqlNodeId" ]; then
    exit 1
fi

SCRIPT_LOCATION=$(getFileLocation ${SCRIPT})

# The first and third methods execute the script as another process, so variables and functions in the other script will not be accessible.
# See http://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script
bash ${SCRIPT_LOCATION}/package_installer.sh "${sqlNodeId}" "mysql-apt-config_*_all.deb" "${SCRIPT}"

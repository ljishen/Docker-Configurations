#!/bin/bash -e

# All the Configuration Documents can be found at
# https://dev.mysql.com/doc/refman/5.6/en/mysql-cluster-install-linux-binary.html

SCRIPT=$0

usage() {
    echo "Usage: `basename ${SCRIPT}` [-h] [CONTAINER_ID <string>]" 1>&2
    exit 1
}

if [ "$1" = "-h" ]; then
    usage
fi

# Import utility functions
source ../utils.sh

SCRIPT_LOCATION=$(getFileLocation ${SCRIPT})

CONTAINER_NAME_PREFIX="sql_node"

if [ $# -eq 0 ]; then
    read -p "Do you want to start a new ${CONTAINER_NAME_PREFIX} container? (yes/no) " yn
    case $yn in
        [Yy]*) # grep -w : match whole word
               counts=$(docker ps | grep -w ${CONTAINER_NAME_PREFIX}_.* | awk '{print $1}' | wc -l)
               newContainerName=${CONTAINER_NAME_PREFIX}_$((${counts}+1))
               source $(dirname ${SCRIPT_LOCATION})/run.sh --tag genomic_v2 --name ${newContainerName} -d -p 2202 -p 22
               containerId=$(findContainerIdByName ${newContainerName})
               ;;
        *    ) echo -e "\nYou can specify a CONTAINER_ID with name of prefix ${CONTAINER_NAME_PREFIX}_" 1>&2
               usage
               ;;
    esac
else
    # WARNNING: We might need to check if the input CONTAINER_ID is valid.
    containerId=$1
fi

echo -e "\nTarget container is ${containerId}"

# Deploy my.cnf
# Automatically find the container id of management node (name=mgm_node).
echo -e "\nDeploying my.cnf..."

MGM_NODE_NAME="mgm_node"
mgmNodeIp=$(findIpByName ${MGM_NODE_NAME})
if [ -z "$mgmNodeIp" ]; then
    exit 1
fi

MY_CNF_TEMPLATE=${SCRIPT_LOCATION}/my_data_sql_node.cnf

content=$(patternReplace ${MY_CNF_TEMPLATE} MGM_NODE_IP=${mgmNodeIp})

MY_CNF_PATH_TMP=${SCRIPT_LOCATION}/my.cnf.tmp
echo "${content}" > ${MY_CNF_PATH_TMP}

docker cp ${MY_CNF_PATH_TMP} ${containerId}:/etc/my.cnf

rm ${MY_CNF_PATH_TMP}

# The first and third methods execute the script as another process, so variables and functions in the other script will not be accessible.
# See http://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script
bash ${SCRIPT_LOCATION}/package_installer.sh "${containerId}" "mysql-cluster-gpl*linux*x86_64.tar.gz" "${SCRIPT}"

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
source utils.sh

SCRIPT_LOCATION=$(getFileLocation ${SCRIPT})

CONTAINER_NAME="mgm_node"

if [ $# -eq 0 ]; then
    # WARNNING: Crash if there are more than one containers found with this name.
    containerId=$(findContainerIdByName "${CONTAINER_NAME}")
    if [ -z "$containerId" ]; then
        read -p "Do you want to start a new ${CONTAINER_NAME} container? (yes/no) " yn
        case $yn in
            [Yy]*) # grep -w : match whole word
                   source $(dirname ${SCRIPT_LOCATION})/run.sh --tag genomic_v2 --name ${CONTAINER_NAME} -d -p 2202
                   containerId=$(findContainerIdByName ${CONTAINER_NAME})
                   ;;
            *    ) echo -e "\nYou can specify a CONTAINER_ID with name of ${CONTAINER_NAME}" 1>&2
                   usage
                   ;;
        esac
    fi
else
    # WARNNING: We might need to check if the input CONTAINER_ID is valid.
    containerId=$1
fi

echo -e "\nTarget container is ${containerId}"

# Query data_nodes and one sql_nodes
# The outermost parentheses converts awk result to array,
# see http://stackoverflow.com/questions/15105135/bash-capturing-output-of-awk-into-array
dataNodes=($(findContainerIdByName "data_node.*"))
sqlNodes=($(findContainerIdByName "sql_node.*"))

if [ ${#dataNodes[@]} -lt 2 ] || [ ${#sqlNodes[@]} -lt 1 ]; then
    echo "Require at least 2 data_node and 1 sql_node." 1>&2
    exit 1
fi

# Prepare IP Addresses of all nodes.
mgmNodeIp=$(findIpByContainerId ${containerId})

dataNodeIps[0]=$(findIpByContainerId ${dataNodes[0]})
dataNodeIps[1]=$(findIpByContainerId ${dataNodes[1]})

sqlNodeIps[0]=$(findIpByContainerId ${sqlNodes[0]})

CONFIG_TEMPLATE_PATH=${SCRIPT_LOCATION}/config.ini
content=$(patternReplace ${CONFIG_TEMPLATE_PATH} MGM_NODE_IP=${mgmNodeIp} DATA_NODE_IP_1=${dataNodeIps[0]} DATA_NODE_IP_2=${dataNodeIps[1]} SQL_NODE_IP=${sqlNodeIps[0]})

CONFIG_TEMPLATE_PATH_TMP=${CONFIG_TEMPLATE_PATH}.tmp
echo "${content}" > ${CONFIG_TEMPLATE_PATH_TMP}

docker exec ${containerId} mkdir -p /var/lib/mysql-cluster
docker cp ${CONFIG_TEMPLATE_PATH_TMP} ${containerId}:/var/lib/mysql-cluster/config.ini

rm ${CONFIG_TEMPLATE_PATH_TMP}

# The first and third methods execute the script as another process, so variables and functions in the other script will not be accessible.
# See http://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script
bash ${SCRIPT_LOCATION}/package_installer.sh "${containerId}" "mysql-cluster-gpl*linux*x86_64.tar.gz" "${SCRIPT}"

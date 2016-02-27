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

# See http://www.cyberciti.biz/faq/unix-linux-appleosx-bsd-bash-script-find-what-directory-itsstoredin/
SCRIPT_LOCATION=$(dirname $(readlink -f ${SCRIPT}))

CONTAINER_NAME="mgm_node"

if [ $# -eq 0 ]; then
    # WARNNING: Crash if there are more than one containers found with this name.
    containerId=$(docker ps | grep -w ${CONTAINER_NAME} | awk '{print $1}')
    if [ -z "$containerId" ]; then
        read -p "Do you want to start a new ${CONTAINER_NAME} container? (yes/no) " yn
        case $yn in
            [Yy]*) # grep -w : match whole word
                   source $(dirname ${SCRIPT_LOCATION})/run.sh --tag genomic_v2 --name ${CONTAINER_NAME} -d -p 2202
                   containerId=$(docker ps | grep -w ${CONTAINER_NAME} | awk '{print $1}')
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
dataNodes=($(docker ps | grep -w "data_node_".* | awk '{print $1}'))
sqlNodes=($(docker ps | grep -w "sql_node_".* | awk '{print $1}'))

if [ ${#dataNodes[@]} -lt 2 ] || [ ${#sqlNodes[@]} -lt 1 ]; then
    echo "Require at least 2 data_node and 1 sql_node." 1>&2
    exit 1
fi

source ${SCRIPT_LOCATION}/utils.sh

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

# The source script can access the current context, since they are executed in the same process.
# See http://stackoverflow.com/questions/8352851/how-to-call-shell-script-from-another-shell-script
source ${SCRIPT_LOCATION}/package_installer.sh

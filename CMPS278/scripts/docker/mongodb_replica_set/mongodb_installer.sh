#!/bin/bash -e


SCRIPT=$0

# Import utility functions
source ../utils.sh

SCRIPT_LOCATION=$(getFileLocation ${SCRIPT})

CONTAINER_NAME_PREFIX="mongodb_node"

read -p "Do you want to start a new ${CONTAINER_NAME_PREFIX} container? (yes/no) " yn
case $yn in
    [Yy]*) # grep -w : match whole word
        counts=$(docker ps | grep -w ${CONTAINER_NAME_PREFIX}_.* | awk '{print $1}' | wc -l)
        newContainerName=${CONTAINER_NAME_PREFIX}_$((${counts}+1))
        source $(dirname ${SCRIPT_LOCATION})/run.sh --tag genomic_v2 --name ${newContainerName} -d -p 27017
        containerId=$(findContainerIdByName ${newContainerName})
        ;;
    *    )
        exit 1
        ;;
esac

echo -e "\nTarget container is ${containerId}"

# :2:3 Remove the first 2 chars and the last 3 chars
REMOTE_SCRIPT="${SCRIPT:2:-3}-remote.sh"

source `dirname ${SCRIPT_LOCATION}`/constants.sh

echo -e "\nCopy ${REMOTE_SCRIPT} to target container"
docker cp ${SCRIPT_LOCATION}/${REMOTE_SCRIPT} ${containerId}:${CONTAINER_DEST}

echo -e "\nDone!\n"
echo "
(1) Execute script ${SCRIPT_LOCATION}/hosts_updater.sh on docker host only once after all ${CONTAINER_NAME_PREFIX}s installed."
echo "
(2) Execute script ${CONTAINER_DEST}/${REMOTE_SCRIPT} in container ${containerId}."

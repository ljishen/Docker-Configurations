#!/bin/bash -e

if [ $# -lt 3 ]; then
    echo "Require at least 3 arguments."
    echo "Usage: `basename $0` <CONTAINER_ID> <PACKAGE_NAME_PATTERN> <CALLING_SCRIPT>"
    exit 1
fi

CONTAINER_ID=$1
PACKAGE_NAME_PATTERN=$2
CALLING_SCRIPT=$3

# Copy MySQL Installation Resources
echo -e "\nCopying Installation Resources to Container..."

# Import utility functions
source ../utils.sh

SCRIPT_LOCATION=$(getFileLocation ${CALLING_SCRIPT})

source `dirname ${SCRIPT_LOCATION}`/constants.sh

packagePath=$(find ${SOFTWARES_FOLDER_PATH} -name "${PACKAGE_NAME_PATTERN}")
package=$(basename ${packagePath})
if [ -z "$package" ]; then
    echo "Cannot find installer package in ${SOFTWARES_FOLDER_PATH}" 1>&2
    exit 1
fi
echo "Found MySQL Installer Package ${package}"

docker cp "${SOFTWARES_FOLDER_PATH}/${package}" "${CONTAINER_ID}:${CONTAINER_DEST}"

# :2:3 Remove the first 2 chars and the last 3 chars
REMOTE_SCRIPT="${CALLING_SCRIPT:2:-3}-remote.sh"

echo "Generating ${REMOTE_SCRIPT}..."

REMOTE_SCRIPT_PATH=${SCRIPT_LOCATION}/${REMOTE_SCRIPT}

content=$(cat ${REMOTE_SCRIPT_PATH})
content=$(sed -e "s@#PACKAGE@${package}@g" <<< "$content")
content=$(sed -e "s@#DEST@${CONTAINER_DEST}@g" <<< "$content")

echo "${content}" > ${REMOTE_SCRIPT_PATH}.tmp

docker cp ${REMOTE_SCRIPT_PATH}.tmp ${CONTAINER_ID}:${CONTAINER_DEST}/${REMOTE_SCRIPT}
docker exec ${CONTAINER_ID} chmod +x ${CONTAINER_DEST}/${REMOTE_SCRIPT}

rm ${REMOTE_SCRIPT_PATH}.tmp

echo -e "\nDone!"
echo "Please execute script ${CONTAINER_DEST}/${REMOTE_SCRIPT} in container ${CONTAINER_ID}."

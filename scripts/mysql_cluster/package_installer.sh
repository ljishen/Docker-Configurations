#!/bin/bash -e

# Copy MySQL Installation Resources
echo -e "\nCopying MySQL Installation Resources to Container..."

CONTAINER_DEST=/var/tmp
SOFTWARES_FOLDER_PATH=$HOME/softwares

packagePath=$(find ${SOFTWARES_FOLDER_PATH} -name "mysql-cluster-gpl*linux*x86_64.tar.gz")
package=$(basename ${packagePath})
if [ -z "$package" ]; then
    echo "Cannot find mysql-cluster installer package in ${SOFTWARES_FOLDER_PATH}" 1>&2
    exit 1
fi
echo "Found MySQL Installer Package ${package}"

docker cp "${SOFTWARES_FOLDER_PATH}/${package}" "${containerId}:${CONTAINER_DEST}"

# :2:3 Remove the first 2 chars and the last 3 chars
REMOTE_SCRIPT="${SCRIPT:2:-3}-remote.sh"

echo "Generating ${REMOTE_SCRIPT}..."

REMOTE_SCRIPT_PATH=${SCRIPT_LOCATION}/${REMOTE_SCRIPT}

content=$(cat ${REMOTE_SCRIPT_PATH})
content=$(sed -e "s@#PACKAGE@${package}@g" <<< "$content")
content=$(sed -e "s@#DEST@${CONTAINER_DEST}@g" <<< "$content")

echo "${content}" > ${REMOTE_SCRIPT_PATH}.tmp

docker cp ${REMOTE_SCRIPT_PATH}.tmp ${containerId}:${CONTAINER_DEST}/${REMOTE_SCRIPT}
docker exec ${containerId} chmod +x ${CONTAINER_DEST}/${REMOTE_SCRIPT}

rm ${REMOTE_SCRIPT_PATH}.tmp

echo -e "\nDone!"
echo "Please execute script ${CONTAINER_DEST}/${REMOTE_SCRIPT} in container ${containerId}."

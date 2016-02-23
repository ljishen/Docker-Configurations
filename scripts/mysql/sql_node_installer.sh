#!/bin/bash -e

if [ $# -eq 0 ]
  then
    echo "Usage: $0 [CONTAINER_ID]"
    exit 0
fi

PACKAGE=mysql-cluster-gpl-7.4.10-linux-glibc2.5-x86_64.tar.gz
DESC=/var/tmp
SCRIPT=$0
CONTAINER_ID=$1

echo "CONTAINER_ID=${CONTAINER_ID}"

echo "Copying resources..."

docker cp "${HOME}/softwares/${PACKAGE}" "${CONTAINER_ID}:${DESC}"

# :2:3 Remove the first 2 chars and the last 3 chars
REMOTE_SCRIPT="${SCRIPT:2:-3}-remote.sh"

# See http://www.cyberciti.biz/faq/unix-linux-appleosx-bsd-bash-script-find-what-directory-itsstoredin/
SCRIPT_LOCATION=$(dirname $(readlink -f ${SCRIPT}))

REMOTE_SCRIPT_PATH=${SCRIPT_LOCATION}/${REMOTE_SCRIPT}

content=$(cat ${REMOTE_SCRIPT_PATH})
content=$(sed -e "s@#PACKAGE@${PACKAGE}@g" <<< "$content")
content=$(sed -e "s@#DESC@${DESC}@g" <<< "$content")

echo "${content}" > ${REMOTE_SCRIPT_PATH}.tmp

docker cp ${REMOTE_SCRIPT_PATH}.tmp ${CONTAINER_ID}:${DESC}/${REMOTE_SCRIPT}
docker exec ${CONTAINER_ID} chmod +x ${DESC}/${REMOTE_SCRIPT}

rm ${REMOTE_SCRIPT_PATH}.tmp

echo "Please execute script ${REMOTE_SCRIPT} in container ${CONTAINER_ID}."

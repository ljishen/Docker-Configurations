#!/bin/bash -e

if [ $# -eq 0 ]
  then
    echo "Usage: $0 [CONTAINER_ID]"
    exit 0
fi

SCRIPT=$0
CONTAINER_ID=$1

echo "CONTAINER_ID is ${CONTAINER_ID}"

# Deploy my.cnf
# Automatically find the container id of management node (name=mgm).
echo -e "\nDeploying my.cnf..."

# grep -w : match whole word
mgmId=$(docker ps | grep -w mgm | awk '{print $1}')

if [ -z "$mgmId" ]; then
    echo "Cannot find management node with name=mgm. Please start management node first."
    exit 0
fi

echo "Container ID of Management Node is ${mgmId}"

MGM_IP=$(docker inspect ${mgmId} | grep \"IPAddress\" | awk 'NR==1{print $2}' | tr -d \",)

echo "IPAddress of Management Node is ${MGM_IP}"

# See http://www.cyberciti.biz/faq/unix-linux-appleosx-bsd-bash-script-find-what-directory-itsstoredin/
SCRIPT_LOCATION=$(dirname $(readlink -f ${SCRIPT}))

MY_CNF_TEMPLATE=${SCRIPT_LOCATION}/my_data_sql_node.cnf

content=$(cat ${MY_CNF_TEMPLATE})
content=$(sed -e "s@#MGM_IP@${MGM_IP}@g" <<< "$content")

MY_CNF_PATH_TMP=${SCRIPT_LOCATION}/my.cnf.tmp

echo "${content}" > ${MY_CNF_PATH_TMP}

docker cp ${MY_CNF_PATH_TMP} ${CONTAINER_ID}:/etc/my.cnf

rm ${MY_CNF_PATH_TMP}

# Install MySQL Server
echo -e "\nInstalling MySQL Server..."

PACKAGE=mysql-cluster-gpl-7.4.10-linux-glibc2.5-x86_64.tar.gz
DESC=/var/tmp

echo "Copying resources..."

docker cp "${HOME}/softwares/${PACKAGE}" "${CONTAINER_ID}:${DESC}"

# :2:3 Remove the first 2 chars and the last 3 chars
REMOTE_SCRIPT="${SCRIPT:2:-3}-remote.sh"

REMOTE_SCRIPT_PATH=${SCRIPT_LOCATION}/${REMOTE_SCRIPT}

content=$(cat ${REMOTE_SCRIPT_PATH})
content=$(sed -e "s@#PACKAGE@${PACKAGE}@g" <<< "$content")
content=$(sed -e "s@#DESC@${DESC}@g" <<< "$content")

echo "${content}" > ${REMOTE_SCRIPT_PATH}.tmp

docker cp ${REMOTE_SCRIPT_PATH}.tmp ${CONTAINER_ID}:${DESC}/${REMOTE_SCRIPT}
docker exec ${CONTAINER_ID} chmod +x ${DESC}/${REMOTE_SCRIPT}

rm ${REMOTE_SCRIPT_PATH}.tmp

echo -e "\nDone!"
echo "Please execute script ${DESC}/${REMOTE_SCRIPT} in container ${CONTAINER_ID}."

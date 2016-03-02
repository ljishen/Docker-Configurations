#!/bin/bash -e

source ../utils.sh

CONTAINER_NAME_PREFIX="mongodb_node"

replicaNodes=($(findContainerIdByName "${CONTAINER_NAME_PREFIX}.*"))

if [ ${#replicaNodes[@]} -lt 3 ]; then
    echo "Please start at least 3 ${CONTAINER_NAME_PREFIX}." 1>&2
    exit 1
fi

HOSTS_FILE=/etc/hosts

for node in "${replicaNodes[@]}"; do
    echo -e "\nUpdate hosts for $node"
    for cid in "${replicaNodes[@]}"; do
        if ! docker exec ${node} grep -q ${cid} ${HOSTS_FILE}; then
            ip=$(findIpByContainerId "$cid")
            docker exec ${node} /bin/bash -c "echo -e '${ip}\t${cid}' >> ${HOSTS_FILE}"
        fi
    done
done

echo -e "\nDone!"

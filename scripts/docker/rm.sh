#!/bin/bash -e

if [ -z "$1" ]; then
    echo "Please specify the CONTAINER_ID as the argument" 1>&2
    echo "Usage: `basename $0` <CONTAINER_ID>" 1>&2
    exit 1
fi

docker stop $1 && docker rm $1

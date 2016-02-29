#!/bin/bash -e

usage() {
    echo "Usage: $0 [-d] [-p <ports>] --tag <string> [--name <string>]"
    exit 0
}

if [ $# -eq 0 ]; then
    usage
fi

while (( "$#" )); do
    if [ "$1" = "--tag" ]; then
        tag=$2
        shift 2
    elif [ "$1" = "--name" ]; then
        name="$1 $2"
        shift 2
    elif [ "$1" = "-d" ]; then
        detached="-d"
        shift
    elif [ "$1" = "-p" ]; then
        ports="${ports} $1 $2"
        shift 2
    fi
done

if [ -z "$ports" ]; then
    ports="-P"
fi

if [ -z "$tag" ]; then
    usage
fi

docker run -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v ~/.screenrc:/root/.screenrc:ro \
    -v ~/.vimrc:/root/.vimrc:ro \
    -v /mnt/nfs/ljishen:/root/volume \
    -v ~/.bash_history:/root/.bash_history \
    ${name} \
    ${detached} \
    ${ports} \
    -ti \
    ljishen/dev:${tag}

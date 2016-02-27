#!/bin/bash -e

usage() {
    echo "Usage: $0 [-d] [-p <ports>] --tag <string> [--name <string>]"
    exit 0
}

if [ $# -eq 0 ]; then
    usage
fi

ports="-P"

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
        ports="$1 $2"
        shift 2
    fi
done

if [ -z "$tag" ]; then
    usage
fi

docker run ${name} ${detached} ${ports} -t -i ljishen/dev:${tag}

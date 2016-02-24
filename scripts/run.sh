#!/bin/bash -e

usage() {
    echo "Usage: $0 [-d] --tag <string> [--name <string>]"
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
    fi
done

if [ -z "$tag" ]; then
    usage
fi

docker run ${name} ${detached} -P -t -i ljishen/dev:${tag}

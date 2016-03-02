#!/bin/bash -e

getFileLocation() {
    local file=$1

    if [ -z "$file" ]; then
        echo "Please specify a file as argument" 1>&2
        echo "Usage: ${FUNCNAME[0]} <file>" 1>&2
        return 1
    fi
 
    # See http://www.cyberciti.biz/faq/unix-linux-appleosx-bsd-bash-script-find-what-directory-itsstoredin/
    echo $(dirname $(readlink -f ${file}))
}


findIpByContainerId() {
    local containerId=$1

    if [ -z "$containerId" ]; then
        echo "Please specify the CONTAINER_ID to inspect." 1>&2
        echo "Usage: ${FUNCNAME[0]} <id>" 1>&2
        return 1
    fi

    local ip=$(docker inspect ${containerId} | grep \"IPAddress\" | awk 'NR==1{print $2}' | tr -d \",)
    echo "The IP Address of container ${containerId} is ${ip}" 1>&2

    # Return result to the calling script
    echo ${ip}
}

# This function that feeds a name pattern, and return a print list of CONTAINER IDs.
findContainerIdByName() {
    local nodeName=$1

    local callingFunc=${FUNCNAME[0]} 
    if [ -n "$2" ]; then
        callingFunc=$2
    fi

    if [ -z "$nodeName" ]; then
        echo "Plase specify the node name to inspect." 1>&2
        echo "Usage: ${callingFunc} <name>" 1>&2

        # The exit status may be explicitly specified by a return statement,
        # otherwise it is the exit status of the last command in the function
        # (0 if successful, and a non-zero error code if not). This exit
        # status may be used in the script by referencing it as $?.
        # See http://tldp.org/LDP/abs/html/complexfunct.html
        return 1
    fi

    # grep -w : match whole word
    local containerId=$(docker ps | grep -w ${nodeName} | awk '{print $1}')
    if [ -z "$containerId" ]; then
        echo "Cannot find container with name ${nodeName}. Please start the container first." 1>&2
        return
    fi

    # 1>&2 is used to redirect the output of echo to stderr,
    # such that $(...) call of this script will not include the output.
    # See https://en.wikipedia.org/wiki/Usage_message
    echo "The CONTAINER ID with name of ${nodeName} is ${containerId}" 1>&2

    echo ${containerId}
}

findIpByName() {
    # It is always recommendable to pass parameters within quotes.
    # See http://stackoverflow.com/questions/19376648/pass-empty-variable-in-bash
    local containerId=$(findContainerIdByName "$1" ${FUNCNAME[0]})
    if [ -z "$containerId" ]; then
        return 1
    fi

    echo $(findIpByContainerId ${containerId})
}

patternReplace() {
    local templateName=$1

    if [ -z "$templateName" ] || [ -z "$2" ]; then
        echo "This function requires at least two arguments." 1>&2
        echo "Usage: ${FUNCNAME[0]} <template> <pattern> [<pattern>...]" 1>&2
        return 1
    else
        # Move to the first pattern.
        shift
    fi

    local content=$(cat ${templateName})
    if [ -z "$content" ]; then
        echo "No contnet for replacement." 1>&2
        return 1
    fi

    while (( "$#" )); do
        # See http://stackoverflow.com/questions/23663963/split-string-into-multiple-variables-in-bash
        IFS='=' read -ra pattern <<< "$1"

        local placeholder=${pattern[0]}
        local replacement=${pattern[1]}

        if [ -z "$placeholder" ] || [ -z "$replacement" ]; then
            echo -e "Ignore pattern ${pattern}\n" 1>&2
        else
            content=$(sed -e "s@#${placeholder}@${replacement}@g" <<< "$content")
        fi

        shift
    done

    echo "$content"
}

#!/bin/bash

if [ -z "${1}" ]; then
    echo "A PATH ARGUMENT IS REQUIRED."
    echo "IT CAN EITHER BE A FILE OR DIRECTORY PATH."
    exit 1
fi

##
## Get path for thisdir
##
THIS_DIR=$(dirname "${0}")
if ! [[ "${THIS_DIR}" = /* ]]; then
    ## Relative path
    THIS_DIR="$(pwd)/${THIS_DIR}"
fi;

##
## Get path for start_point
##
if [[ "${1}" = /* ]]; then
    ## Absolute path
    start_point="${1}"
else
    ## Relative path
    start_point="$(pwd)/${1}"
fi;

if [ -d "${start_point}" ]; then
    ##
    ## Is a Directory
    ##

    ## Change to dir
    cd ${start_point}

    ##
    ## Get python files
    ##
    files=$(
        find . \
            -type f -and \
            -iname "*.py" -and \
            \( \
                -not \
                \( \
                    -iwholename "*/tests/*" -or \
                    -iwholename "*/test/*" -or \
                    -iwholename "*/.git/*" -or \
                    -iwholename "*/migrations/*" -or \
                    -iname "test_*.py" \
                \) \
            \)
    )
elif [ -f "${start_point}" ]; then
    ##
    ## Is a file
    ##

    ## Change to dir
    cd $(dirname ${start_point})
    files="${start_point}"
else
    ##
    ## Something else
    ##
    echo "PATH ARGUMENT IS NOT A VALID DIRECTORY OR FILE PATH."
    exit 1
fi;

##
## Cycle through files
##
for file in ${files}; do
    bash "${THIS_DIR}/validate-file.bash" "${file}"
    if [ ${?} -ne 0 ]; then
        #echo "STOPPING."
        exit 1
    fi;
done;

exit 0


#!/bin/bash

INPUT_FILE="${1}"
THIS_DIR=$(dirname "${0}")
PYLINT_RC=$(readlink -f "${THIS_DIR}/pylintrc")

#echo "FILE: ${INPUT_FILE}"

##
## Make sure is a python file
##
fname=$(basename "${INPUT_FILE}")
fext="${fname##*.}"
if [ "${fext}" != "py" ]; then
    echo "INVALID FILENAME"
    exit 1
fi;

##
## If file is completely empty,
## no need to actually check it
##
if ! [ -s "${INPUT_FILE}" ]; then
    exit 0
fi;

##
## PEP8
##
pep_res=$(pep8 "${INPUT_FILE}" 2>&1)
pep_status=${?}
if [ ${pep_status} -ne 0 ]; then
    echo
    echo "CODE DOES NOT PASS PEP8. FILE:"
    echo
    echo "> ${INPUT_FILE}"
    echo
    echo -e "${pep_res}"
    echo
    exit 1
fi

##
## PYLINT
##
## Need to inline disable messages here
## since they are not respected from rcfile
##
pylint_res=$(
     pylint \
         --rcfile="${PYLINT_RC}" \
         --disable="I0011" \
         --disable="W0212" \
         --disable="F0401" \
         --disable="W0232" \
         --disable="R0201" \
         --disable="W0142" \
         --disable="W0511" \
         --disable="W0613" \
         --disable="W0110" \
         --disable="C0325" \
         "${INPUT_FILE}" 2>&1
)
pylint_status=${?}
if [ ${pylint_status} -ne 0 ]; then
    echo
    echo "CODE DOES NOT PASS PYLINT. FILE:"
    echo
    echo "> ${INPUT_FILE}"
    echo
    echo -e "${pylint_res}"
    echo
    exit 1
fi

##
## Exit success
##
exit 0


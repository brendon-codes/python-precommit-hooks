#!/bin/bash

##
## This script assumes that the following env
## vars will exit
##
##  * REPO_DIR:
##    Absolute path to the repo being processed.
##  * ROOT_DIR:
##    Absolute path to root repo
##  * VALIDATION_DIR:
##    Absolute path to the python-vlidation directory
##

if [[ -z "${REPO_DIR}" || ! -d "${REPO_DIR}" ]]; then
    echo "REPO_DIR is not set correctly."
    exit 1
fi;
if [[ -z "${VALIDATION_DIR}" || ! -d "${VALIDATION_DIR}" ]]; then
    echo "VALIDATION_DIR is not set correctly."
    exit 1
fi;

CHECK_TYPES=(
    "A"
    "M"
)

CHECK_EXTENSIONS=(
    "py"
)

cd "${REPO_DIR}/"
changed_files=$(git status --porcelain)

#echo "Changed Files: #${changed_files}#"

## Loop through changed rows
IFS_OLD="${IFS}"
IFS=""
while read -r changed_row; do
    #echo "Changed: #${changed_row}#"
    ## Staged files
    fstatus_staged="${changed_row:0:1}"
    ## Unstaged files
    fstatus_unstaged="${changed_row:1:1}"
    ## Filepath
    fpath="${changed_row:3}"
    ## Filename
    fname=$(basename "${fpath}")
    ## File extensions
    fext="${fname##*.}"
    #echo "Filepath: #${fpath}#"
    #echo "Filename: #${fname}#"
    #echo "Fileext: #${fext}#"
    ## If does not match a correct extension
    ## then continue
    if ! [[ "${CHECK_EXTENSIONS[@]}" =~ "${fext}" ]]; then
        #echo "Skipping (Extension): #${fpath}#, #${fext}#"
        continue;
    fi;
    ## Make sure is not an excluded file
    find_count=$(find \
            "${fpath}" \
            \( -type f \) \
            \( -not -path "migrations/*" \) \
            \( -not -path "*/migrations/*" \) \
            \( -not -path "tests/*" \) \
            \( -not -path "*/tests/*" \) \
            \( -not -name "test_*.py" \) | wc -l)
    #echo "FINDCOUNT: ${find_count}"
    if [ ${find_count} -eq 0 ]; then
        continue
    fi;
    ## If status type is one of the ones that
    ## we want to check
    if [[ "${CHECK_TYPES[@]}" =~ "${fstatus_staged}" ]]; then
        #echo "Checking: ${fpath}"
        bash "${VALIDATION_DIR}/validate-file.bash" "${fpath}"
        ## Exit with failure if no pass
        if [ ${?} -ne 0 ]; then
            #echo "Failed: ${fpath}"
            exit 1
        else
            :
            #echo "Passed: ${fpath}"
        fi
    else
        :
        #echo "Skipping (Unstaged): #${fpath}#"
    fi
done <<< "${changed_files}"
IFS="${IFS_OLD}"

exit 0

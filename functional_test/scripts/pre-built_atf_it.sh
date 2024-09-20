#!/bin/bash
export CFG=$1
export TP=$2
export RE_TP=$3
export env_file=$4

source ${env_file}
source ${PLATFORM_SCRIPTS}/atf_it_helper_funcs.sh # The functions to build ATF and El1 are in atf_it_helper_funcs.sh

echo "PROJECT_BINARY_DIR: $PROJECT_BINARY_DIR"
echo "SCRIPTS:$SCRIPTS"
echo "PLATFORM_SCRIPTS:$PLATFORM_SCRIPTS"
echo " Prefix build for ATF"

array=()
declare -a array=([0]=${CFG} [1]=${TP} [2]=${RE_TP})

echo "build CFG:${array[0]}, TP: ${array[1]}"

# If pre-TP is the same with the current TP: no checkout; else checkout to another TP commit
if [ $RE_TP -eq $TP ];then
    if [ -n "$(git status --porcelain)" ]; then
        echo "there are changes"
        git reset --hard
    else
        echo "no changes"
    fi

else
    python3 $SCRIPTS/checkout_to_commit.py "$TP" "$SCRIPTS" "$PROJECT_BINARY_DIR"
fi

# Build ATF/EL1 for each test case
    build_atf ${CFG} ${TP}

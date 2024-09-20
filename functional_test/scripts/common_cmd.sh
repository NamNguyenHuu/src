#!/bin/bash
export PROJECT_BINARY_DIR
source ${PROJECT_BINARY_DIR}/atf_it_env.sh
source ${PLATFORM_SCRIPTS}/atf_it_helper_funcs.sh

echo "BUILD_4BOARD: $BUILD_4BOARD"
echo "SCRIPTS:$SCRIPTS"
echo "PROJECT_SOURCE_DIR:$PROJECT_SOURCE_DIR"
echo "COMMAND : ${COMMAND_USED}"

export binary_local_path=${binary_local_path}
export BUILT_RESULT_BINARY_DIR
export TEST_ALL
export BUILD_CFG=$1
export TP=$2
export burn_mode=$3
export test_sheet=$4
export TEST_ID=$5

echo "BUILT_RESULT: $BUILT_RESULT_BINARY_DIR"

build_atf "$BUILD_CFG" "$TP" "$burn_mode" "$test_sheet" "$TEST_ID"
# Rename bl31 image
python3 ${SCRIPTS}/naming_output.py "$BUILD_CFG" "$TP" "$BUILD_4BOARD" "$binary_local_path" "$PROJECT_BINARY_DIR"

# Check if secure boot
check_test_case "${is_secure_boot}" "${TA_ENC}"

# burn image and reboot board
burn_reboot_board_exec_test "$BUILD_CFG" "$TP" "$burn_mode" "$test_sheet" "$TEST_ID"

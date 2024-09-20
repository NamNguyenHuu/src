#!/bin/bash
export BUILD_CFG=$1
export TP=$2
export burn_mode=$3
export test_sheet=$4
export TEST_ID=$5

source ${PLATFORM_SCRIPTS}/atf_it_helper_funcs.sh
burn_reboot_board_exec_test "$BUILD_CFG" "$TP" "$burn_mode" "$test_sheet" "$TEST_ID"

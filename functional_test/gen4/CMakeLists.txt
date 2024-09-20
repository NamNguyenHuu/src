
#######################################################################################################################
# Copyright [2023] Renesas Electronics Corporation and/or its licensors. All Rights Reserved.
#
# The contents of this file (the "contents") are proprietary and confidential to Renesas Electronics Corporation
# and/or its licensors ("Renesas") and subject to statutory and contractual protections.
#
# Unless otherwise expressly agreed in writing between Renesas and you: 1) you may not use, copy, modify, distribute,
# display, or perform the contents; 2) you may not use any name or mark of Renesas for advertising or publicity
# purposes or in connection with your use of the contents; 3) RENESAS MAKES NO WARRANTY OR REPRESENTATIONS ABOUT THE
# SUITABILITY OF THE CONTENTS FOR ANY PURPOSE; THE CONTENTS ARE PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
# NON-INFRINGEMENT; AND 4) RENESAS SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, OR CONSEQUENTIAL DAMAGES,
# INCLUDING DAMAGES RESULTING FROM LOSS OF USE, DATA, OR PROJECTS, WHETHER IN AN ACTION OF CONTRACT OR TORT, ARISING
# OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THE CONTENTS. Third-party contents included in this file may
# be subject to different terms.
########################################################################################################################
message(STATUS "Start ATF IT for R-Car Gen4")

cmake_minimum_required(VERSION 3.12)
set(PLATFORM_SCRIPTS "${PROJECT_SOURCE_DIR}/${CURRENT_PLATFORM}/scripts")

# Automatically include feature's cmakelist.txt file
file(   GLOB cmake_feature_SRC
        LIST_DIRECTORIES false
        CONFIGURE_DEPENDS gen4/atf_it*cmakelist.txt
    )

foreach (feature_cmakelist ${cmake_feature_SRC})
    message("Include file: ${feature_cmakelist}")
    include(${feature_cmakelist})
endforeach ()

set(
    TP_MAPPING_TABLE
    # TP    atf_commit              smc_dummy_commit
    "2      ${atf_git_commit_id}    ${smc_dummy_commit_id}"
    "10      ${atf_git_commit_id}    ${smc_dummy_commit_id}"
    "7      ${atf_git_commit_id_tp7}    ${smc_dummy_commit_id}"
    "7_8    ${atf_git_commit_id_tp7}	${smc_dummy_commit_id}"
    "6    ${atf_git_commit_id_tp6}	${smc_dummy_commit_id}"
    "0 	  ${atf_git_commit_id} 		${smc_dummy_commit_id}"
    "4 	  ${atf_git_commit_id_tp4} 		${smc_dummy_commit_id}"
    "25  ${atf_git_commit_id}		${smc_dummy_commit_id}"
    "28  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "27  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "29  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "26  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "210  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "211  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "22  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "23  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "216  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "219  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "218  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
    "213 ${atf_git_commit_id_tp6}          ${smc_dummy_commit_id}"
    "214  ${atf_git_commit_id_tp6}          ${smc_dummy_commit_id}"
    "212  ${atf_git_commit_id}          ${smc_dummy_commit_id}"
)

file(WRITE ${PROJECT_SOURCE_DIR}/scripts/TP_Mapping_Table.txt "")
FOREACH(TP_Mapping_Table ${TP_MAPPING_TABLE})
    FILE(APPEND ${PROJECT_SOURCE_DIR}/scripts/TP_Mapping_Table.txt "${TP_Mapping_Table}\r")
ENDFOREACH(TP_Mapping_Table)

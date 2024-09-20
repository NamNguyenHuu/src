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
#######################################################################################################################

#### Arm Trusted Firmware Gen3
set(app_name         "arm_trusted_firmware_test_functional_test")
project(${app_name})

## Build set-up.
set(build_info              "/shsv/Android/SoftIP/sec_bsp/build_info")
set(ATF_SRC                 "git@rcar-env.dgn.renesas.com:securitybsp/arm-trusted-firmware.git")  # for internal use only
set(binary_local_path       "${CMAKE_CURRENT_BINARY_DIR}/binaries_dir")
set(BUILT_RESULT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/out/prepare/prefix_build_atf")


# Build ATF test app
add_custom_target(${app_name} ALL
    DEPENDS
        "${CMAKE_CURRENT_BINARY_DIR}/arm-trusted-firmware/Makefile"
        "${binary_local_path}"
        "${BUILT_RESULT_BINARY_DIR}"
)


#----------------------------------------------------------------------------------------------------------------------
# R-Car xOS SoC/Board selection
#----------------------------------------------------------------------------------------------------------------------

if(NOT RCAR_SOC) # This guard allows to set RCAR_SOC externally, e.g. via CMake Commandline during configuration
    set(RCAR_SOC "s4")
endif()

if(NOT CURRENT_PLATFORM)
    if(RCAR_SOC STREQUAL "s4")
        set(CURRENT_PLATFORM "gen4")
    endif()

    if (($ENV{LSI_VARIANT} STREQUAL "h3")
    OR ($ENV{LSI_VARIANT} STREQUAL "m3")
    OR ($ENV{LSI_VARIANT} STREQUAL "m3n")
    OR ($ENV{LSI_VARIANT} STREQUAL "e3"))
        set(CURRENT_PLATFORM "gen3")
    endif()
endif()

if(CURRENT_PLATFORM STREQUAL "gen3")
    include(gen3/commit.cmake)
elseif(CURRENT_PLATFORM STREQUAL "gen4")
    include(gen4/commit.cmake)
endif()


#### git checkout source code of arm-trusted-firmware (in build dir)
find_program(
    GIT_CMD
    NAME git
    PATHS /usr/bin
    DOC "git version control app location"
)

if(NOT EXISTS "${GIT_CMD}")
    message(FATAL_ERROR "It was not possible to find the git program. Stop!")
else()
    add_custom_command(
        OUTPUT
            "${CMAKE_CURRENT_BINARY_DIR}/arm-trusted-firmware/Makefile"
        COMMAND
            rm -rf "${CMAKE_CURRENT_BINARY_DIR}/arm-trusted-firmware"
        COMMAND
  	    ${GIT_CMD} clone ${ATF_SRC}
        COMMAND
            cd "${CMAKE_CURRENT_BINARY_DIR}/arm-trusted-firmware" && ${GIT_CMD} checkout -f ${atf_git_commit_id}
        COMMAND
            ${CMAKE_COMMAND} -E echo "ATF: git checkout step completed!"
        VERBATIM
    )
endif()

## ===========================================================================================
## Load other ipl binary files from Artifactory

# S4 IPL loaders/Linux Yocto binaries download
if($ENV{LSI_VARIANT} STREQUAL "s4")
    add_custom_command(
        OUTPUT
            "${binary_local_path}"
        COMMAND
            ${CMAKE_COMMAND} -E make_directory "${binary_local_path}"
        COMMAND
            ${CMAKE_COMMAND} -E echo "${binary_local_path}"
        COMMAND
            ${CMAKE_COMMAND} -E copy
            "${build_info}/ipl_burning.py"
            "${build_info}/ipl_burning.json"
            "${binary_local_path}"

        DEPENDS
            "${binary_local_path}"
            "${build_info}/ipl_burning.py"
            "${build_info}/ipl_burning.json"
        VERBATIM
    )

    set(ipl_default_version      "0.19.0")
    set(yocto_default_version      "5.15.0")

    set(ipl_binary_remote_path  "rcar-tools/renesas/ipl/${ipl_default_version}/s4/bin/default-CA_IPL/s4")
    set(yocto_binary_remote_path  "rcar-tools/renesas/yocto_linux/${yocto_default_version}")

    set(ipl_binary_files
        bootparam_sa0.srec
        cert_header_sa9.srec
        dummy_fw.srec
        dummy_rtos.srec
        dummy_g4mh_case0.srec
        dummy_icumh_case1.srec
        AArch64_Dummy_CA55_Program.srec # change (maybe)
        AArch64_Dummy_CA55_Program2.srec
        AArch64_Dummy_CA55_Program3.srec
        ca55_loader.srec
        icumx_loader.srec
        tfmv_ver_tbl.bin
        ntfmv_ver_tbl.bin
    )
    set(yocto_binary_files
        u-boot-elf-spider.srec
        tee-spider.srec
    )

    ## For download CPLD tool
    set(cpld_default_version    "1.7.1")
    set(cpld_remote_path        "rcar-test-data/xen/spider/gamma/ipl")
    set(cpld_binary_file        "cpld-control-${cpld_default_version}" )

elseif(($ENV{LSI_VARIANT} STREQUAL "m3") AND ($ENV{RUNNER_BOARD} STREQUAL "salvator-xs"))
    set(PREBUILT_BIN_DIR "/shsv/RCarSW/rvc_git_repo/yocto/_YOCTO_IMAGES_/Gen3/v5.9.0/Images-PT3/MMP/M3")

    add_custom_command(
        OUTPUT "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E echo "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
            "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
            "${build_info}/ipl_burning.py"
            "${build_info}/ipl_burning.json"
             ${binary_local_path}

        DEPENDS "${binary_local_path}"
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
            "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
            "${build_info}/ipl_burning.py"
            "${build_info}/ipl_burning.json"
        VERBATIM
    )
elseif($ENV{LSI_VARIANT} STREQUAL "h3" AND $ENV{RUNNER_BOARD} STREQUAL "salvator-xs" )
    set(PREBUILT_BIN_DIR "/shsv/RCarSW/rvc_git_repo/yocto/_YOCTO_IMAGES_/Gen3/v5.9.0/Images-PT3/MMP/H3")
    add_custom_command(
        OUTPUT "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E echo "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
                "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
                "${build_info}/ipl_burning.py"
                "${build_info}/ipl_burning.json"
                ${binary_local_path}

        DEPENDS "${binary_local_path}"
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
                "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
                "${build_info}/ipl_burning.py"
                "${build_info}/ipl_burning.json"
        VERBATIM
    )
elseif($ENV{LSI_VARIANT} STREQUAL "m3n" AND $ENV{RUNNER_BOARD} STREQUAL "salvator-xs" )
    set(PREBUILT_BIN_DIR "/shsv/RCarSW/rvc_git_repo/yocto/_YOCTO_IMAGES_/Gen3/v5.9.0/Images-PT3/MMP/M3N")
    add_custom_command(
        OUTPUT "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E echo "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
                "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
                "${build_info}/ipl_burning.py"
                "${build_info}/ipl_burning.json"
                ${binary_local_path}

        DEPENDS "${binary_local_path}"
            "${PREBUILT_BIN_DIR}/tee-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-salvator-x.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-salvator-x.tar.bz2"
                "${build_info}/M3/AArch64_Gen3_H3_M3_Scif_MiniMon_V5.11.mot"
                "${build_info}/ipl_burning.py"
                "${build_info}/ipl_burning.json"
        VERBATIM
    )

elseif(($ENV{LSI_VARIANT} STREQUAL "e3") AND ($ENV{RUNNER_BOARD} STREQUAL "ebisu"))
    set(PREBUILT_BIN_DIR "/shsv/RCarSW/rvc_git_repo/yocto/_YOCTO_IMAGES_/Gen3/v5.9.0/Images-PT3/MMP/E3")

    add_custom_command(
        OUTPUT "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E echo "${binary_local_path}"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${PREBUILT_BIN_DIR}/bl2-ebisu-4d.srec"
            "${PREBUILT_BIN_DIR}/bl31-ebisu-4d.srec"
            "${PREBUILT_BIN_DIR}/bootparam_sa0-4d.srec"
            "${PREBUILT_BIN_DIR}/cert_header_sa6-4d.srec"
            "${PREBUILT_BIN_DIR}/cert_header_sa6.srec"
            "${PREBUILT_BIN_DIR}/tee-ebisu.srec"
            "${PREBUILT_BIN_DIR}/u-boot-elf-ebisu.srec"
            "${PREBUILT_BIN_DIR}/core-image-weston-ebisu.tar.bz2"
                "${build_info}/E3/AArch64_Gen3_E3-4D_Scif_MiniMon_V5.03A.mot"
                "${build_info}/ipl_burning.py"
                "${build_info}/ipl_burning.json"
                ${binary_local_path}

        DEPENDS "${binary_local_path}"
        "${PREBUILT_BIN_DIR}/bl2-ebisu-4d.srec"
        "${PREBUILT_BIN_DIR}/bl31-ebisu-4d.srec"
        "${PREBUILT_BIN_DIR}/bootparam_sa0-4d.srec"
        "${PREBUILT_BIN_DIR}/cert_header_sa6-4d.srec"
        "${PREBUILT_BIN_DIR}/cert_header_sa6.srec"
        "${PREBUILT_BIN_DIR}/tee-ebisu.srec"
        "${PREBUILT_BIN_DIR}/u-boot-elf-ebisu.srec"
        "${PREBUILT_BIN_DIR}/core-image-weston-ebisu.tar.bz2"
            "${build_info}/E3/AArch64_Gen3_E3-4D_Scif_MiniMon_V5.03A.mot"
            "${build_info}/ipl_burning.py"
            "${build_info}/ipl_burning.json"
        VERBATIM
    )
endif()


if(CURRENT_PLATFORM STREQUAL "gen4")
#======================================================================================================================
# DO NOT CHANGE ANYTHING BELOW THIS LINE, except you know what to do ;)
#======================================================================================================================
# Download IPL Binaries
rcar_artifactory_download(BINARY
    TARGET          ${app_name}
    REMOTE_PATH     ${ipl_binary_remote_path}
    LOCAL_PATH      ${binary_local_path}
    FILES           ${ipl_binary_files}
)

# Download Yocto Binaries
rcar_artifactory_download(BINARY
    TARGET          ${app_name}
    REMOTE_PATH     ${yocto_binary_remote_path}
    LOCAL_PATH      ${binary_local_path}
    FILES           ${yocto_binary_files}
)

# Download cpld Binaries
rcar_artifactory_download(BINARY
    TARGET          ${app_name}
    REMOTE_PATH     ${cpld_remote_path}
    LOCAL_PATH      ${binary_local_path}
    FILES           ${cpld_binary_file}
)

# Download Flashwriter Binaries
rcar_artifactory_download(BINARY
    TARGET          ${app_name}
    REMOTE_PATH     "rcar-tools/renesas/flash_writer/0.10.0/s4/s4"
    LOCAL_PATH      ${binary_local_path}
    FILES           "ICUMX_Flash_writer_SCIF_DUMMY_CERT_EB203000_S4.mot"
)
endif()
string(TOLOWER "${CMAKE_C_COMPILER_ID}"          compiler_id)
string(TOLOWER "${CMAKE_BUILD_TYPE}"             build_type)


#####------Export env variables for Shell-------#####
set(env_file  "${PROJECT_BINARY_DIR}/atf_it_env.sh")
execute_process( COMMAND cp -rf "${PROJECT_SOURCE_DIR}/atf_it_env_base.sh" "${env_file}") #change 2nd to bin_dir
file(APPEND ${env_file} "\n")
file(APPEND ${env_file} "export CMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}\n")
file(APPEND ${env_file} "export PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}\n")
file(APPEND ${env_file} "export SCRIPTS=${PROJECT_SOURCE_DIR}/scripts\n")
file(APPEND ${env_file} "export PROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}\n")
file(APPEND ${env_file} "export binary_local_path=${binary_local_path}\n")
file(APPEND ${env_file} "export BUILT_RESULT_BINARY_DIR=${BUILT_RESULT_BINARY_DIR}\n")
file(APPEND ${env_file} "export PLATFORM_SRC_DIR=${PROJECT_SOURCE_DIR}/${CURRENT_PLATFORM}\n")
file(APPEND ${env_file} "export PLATFORM_SCRIPTS=${PROJECT_SOURCE_DIR}/${CURRENT_PLATFORM}/scripts\n")
file(APPEND ${env_file} "export ATF_SRC_DIR=${CMAKE_CURRENT_BINARY_DIR}/arm-trusted-firmware\n")



## [Prepare for TEST_DEF] Collection of target test case for running test
set(
    TEST_FEATURE_LIST_CMAKE
)

## [Prepare for TEST_DEF]
## check_target_tc(): filter target test case for running test function.
## Filter bases on: "platforms_support, boards_support, test_feature, test_id" test definition.
function(check_target_tc platforms_support boards_support test_feature test_id is_target_tc)
    # Checking LSI_VARIANT
    set(ret "false")
    foreach(item ${platforms_support})
        if((item STREQUAL "all") OR (item STREQUAL $ENV{LSI_VARIANT}))
            set(ret "true")
            break()
        endif()
    endforeach()

    # Checking RUNNER_BOARD
    set(ret1 "false")
    if(ret STREQUAL "true")
        foreach(board ${boards_support})
            if((board STREQUAL "all") OR (board STREQUAL $ENV{RUNNER_BOARD}))
                set(ret1 "true")
                break()
            endif()
        endforeach()
    endif()

    set(ret2 "false")
    if ( ret1 STREQUAL "true" )
        # Checking TEST_FEATURE
        set(ret2_1 "false")
        if ( NOT DEFINED ENV{TEST_FEATURE} )
            set(ret2 "true") # Test all defined test cases (default)
        else()
            # Loop to check in case multiple test features are defined in ENV{TEST_FEATURE}
            foreach(t_feature $ENV{TEST_FEATURE})
                if ("${t_feature}" STREQUAL "${test_feature}")
                    set(ret2_1 "true")
                    break()
                endif()
            endforeach()
        endif()

        # Checking TEST_ID
        if ( "${ret2_1}" STREQUAL "true" )
            if ( NOT DEFINED ENV{TEST_ID} )
                set(ret2 "true") # Test all test cases of feature(s) in ENV{TEST_FEATURE}
            else()
                # Loop to check in case multiple test_id(s) are defined in ENV{TEST_ID}
                foreach(t_id $ENV{TEST_ID})
                    if ("${t_id}" STREQUAL "${test_id}")
                        set(ret2 "true") # Test only test cases that is included in ENV{TEST_ID}
                        break()
                    endif()
                endforeach()
            endif()
        endif()
    endif()

    set(is_target_tc "${ret2}" PARENT_SCOPE)
    return(is_target_tc)
endfunction()

macro(TEST_DEF TestName TestFeature TestID TARGET_PLATFORM TARGET_BOARD)
    set (is_target_tc "false")
    check_target_tc ("${TARGET_PLATFORM}" "${TARGET_BOARD}" "${TestFeature}" "${TestID}" is_target_tc)

    if ( is_target_tc STREQUAL "true" )
        list(APPEND TEST_FEATURE_LIST_CMAKE ${TestID} ${TestFeature}) # format of TEST_FEATURE_LIST_CMAKE: value1;value2;...
        add_test(NAME ${app_name}_${TestName}_${CURRENT_PLATFORM}-baremetal-${compiler_id}-${RCAR_XIL}-${build_type}
            COMMAND python3 "${PROJECT_SOURCE_DIR}/${CURRENT_PLATFORM}/atf_it_${TestFeature}_script.py" "${TestFeature}" "${TestID}" "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}"
        )

        set_tests_properties(
            ${app_name}_${TestName}_${CURRENT_PLATFORM}-baremetal-${compiler_id}-${RCAR_XIL}-${build_type}
            PROPERTIES
            FAIL_REGULAR_EXPRESSION "test cases of which * failed;ATF_ERROR_"
        )
    endif()
endmacro()

#======================================================#
# Create a directory {BUILT_RESULT_BINARY_DIR}
# Run Build_BIN_For_TestList function and execute the script build_burn_preparing_helpers.py
#======================================================#

## [ Prepare for pre_built ATF ]
## Calling this function must be after TEST_DEF invoking (in feature cmakelist).
function(Build_BIN_For_TestList  CURRENT_PLATFORM)
    message(STATUS "list is in processing....")
    add_custom_command(
        OUTPUT
            "${BUILT_RESULT_BINARY_DIR}"
        COMMAND
            ${CMAKE_COMMAND} -E make_directory "${BUILT_RESULT_BINARY_DIR}"
        COMMAND
            ${CMAKE_COMMAND} -E env "CURRENT_PLATFORM=${CURRENT_PLATFORM}" python3 ${PROJECT_SOURCE_DIR}/scripts/build_process/build_burn_preparing_helpers.py "${TEST_FEATURE_LIST_CMAKE}" "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}" "${env_file}" "ENV{TEST_SORTING_LEVEL}"
        COMMENT "Running Pre_built_ATF........"
        VERBATIM
)
endfunction()

# Include current platform & build binary,
# This step will scan TEST_DEF is included in {current_platform}/atf_it*_cmakelist.txt files
include(${CURRENT_PLATFORM}/CMakeLists.txt)

## Call after TEST_DEF from platform CMakeLists (also feature CMakelists)
Build_BIN_For_TestList("${CURRENT_PLATFORM}")

#==================================================================================================================
# ADD Static TEST CASES
#==================================================================================================================
# TBD

#==================================================================================================================
# ADD Coverage test TEST CASES
#==================================================================================================================
# TBD

#==================================================================================================================
# ADD IT TEST CASES
#==================================================================================================================
# TOOLCHAIN_PATH is got from rcar-env\cmake\toolchain_poky_3_1_11_gateway.cmake
# set(CI_PROJECT_DIR $ENV{CI_PROJECT_DIR})

# Test case: arm_trusted_firmware_test_functional_test_s4-baremetal-gcc-hil-release
# set(test_name ${app_name}_${RCAR_SOC}-baremetal-${compiler_id}-${RCAR_XIL}-${build_type})

# set(ATF_BUILT_CONF  "PLAT=rcar_gen4 LSI=S4 SPD=opteed MBEDTLS_COMMON_MK=1 CTX_INCLUDE_AARCH32_REGS=0 LOG_LEVEL=10 DEBUG=0")
# add_test(NAME ${test_name}
#     COMMAND "${CI_PROJECT_DIR}/renesas/tools/security_bsp/arm_trusted_firmware/test/functional_test/scripts/atf_it_target_test.sh"
#             ${TOOLCHAIN_PATH} ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${ATF_BUILT_CONF}
# )

## Currently, no need to add property for ATF IT.
# set_target_properties(${app_name} PROPERTIES SOURCES "${sources}")

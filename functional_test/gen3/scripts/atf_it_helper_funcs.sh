#!/bin/bash

if [ -z "$PROJECT_BINARY_DIR" ];then
    export PROJECT_BINARY_DIR=$PROJECT_BINARY_DIR
	echo "PROJECT_BINARY_DIR=$PROJECT_BINARY_DIR"
fi
source ${PROJECT_BINARY_DIR}/atf_it_env.sh
############################################################################
# Function definition
############################################################################
unset LD_LIBRARY_PATH

#==================Build atf =============#
atf_configs_loader=(
    ""
	"LSI=H3 RCAR_DRAM_SPLIT=1 RCAR_DRAM_LPDDR4_MEMCONF=0 RCAR_LOSSY_ENABLE=0 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0 LIFEC_DBSC_PROTECT_ENABLE=0" #1  (default)
        "LSI=H3 RCAR_DRAM_SPLIT=1 RCAR_DRAM_LPDDR4_MEMCONF=0 RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0" #2
	"" #3
	"" #4
	"" #5
	"LSI=M3 RCAR_DRAM_SPLIT=2 RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0" #6
	"LSI=M3 RCAR_DRAM_SPLIT=2 RCAR_LOSSY_ENABLE=0 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0 LIFEC_DBSC_PROTECT_ENABLE=0" #7
	"LSI=M3 RCAR_DRAM_SPLIT=2 RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0 SPD=none" #8
	"LSI=M3 RCAR_DRAM_SPLIT=2 RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0" #9 using only Range_check(Fail)
	"LSI=M3 RCAR_DRAM_SPLIT=2 RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0" #10 using only Range_check(BL2: Booting BL31)
	"LSI=M3N RCAR_LOSSY_ENABLE=1 PSCI_DISABLE_BIGLITTLE_IN_CA57BOOT=0" #11
	"" #12
	"" #13
	"" #14
	"" #15
	"LSI=E3 RCAR_LOSSY_ENABLE=1 RCAR_SA0_SIZE=0 RCAR_AVS_SETTING_ENABLE=0 RCAR_DRAM_DDR3L_MEMCONF=1 RCAR_DRAM_DDR3L_MEMDUAL=1" #16
	"" #17
	"" #18
	"" #19
 	"" #20
)

function build_atf(){
    ######################################################################################################################
    # Run "make" to build ATF with the configs declared in atf_configs_gen4                                              #
    # Then copy the output files to each ${OUTDIR_ATF} for each TP                                                       #
    # About:                                                                                                             #
    #       TP2: Burn to board el1 instead of uboot                                                                      #
    #       Tp10: Change dtb to Disable cpu-idle behavior on Linux                                                       #
    #       TP0: run without TP                                                                                          #
    # ####################################################################################################################

    echo "======= BUILD ATF ======="
    export PROJECT_BINARY_DIR
    BUILD_CFG=$1
    TP=$2
    burn_mode=$3
    test_sheet=$4
    TEST_ID=$5

    ##---------------------------- Build ATF -------------------------##
    cd "${ATF_SRC_DIR}"

    echo "Build with cfg number: $BUILD_CFG (${atf_configs_loader[$BUILD_CFG]})"
    echo "Test ID is: $TEST_ID"
    echo "Test sheet is: $test_sheet"
    if [ "$TP" = "2" ]; then
    	make distclean
	cd ${PROJECT_SOURCE_DIR}/gen3/scripts && ./Range_check.sh $TEST_ID
    	cd "${ATF_SRC_DIR}"
    	make bl2 bl31 rcar_layout_tool rcar_srecord PLAT=rcar SPD=opteed MBEDTLS_COMMON_MK=1 ${atf_configs_loader[$BUILD_CFG]}
    else
	make distclean
	make bl2 bl31 rcar_layout_tool rcar_srecord PLAT=rcar SPD=opteed MBEDTLS_COMMON_MK=1 ${atf_configs_loader[$BUILD_CFG]}
    fi
    ##---------------------Copy ATF output ---------------------------##
    case "$TP" in
        2)
        echo "Create output folder for TP-002"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_2"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar/release/bl31.bin ]; then
            cp build/rcar/release/bl31.srec   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp build/rcar/release/bl2.srec   ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/release/bl2.bin    ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp tools/renesas/rcar_layout_create/bootparam_sa0.srec    ${OUTDIR_ATF}/bootparam_sa0_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp tools/renesas/rcar_layout_create/cert_header_sa6.srec    ${OUTDIR_ATF}/cert_header_sa6_${BUILD_CFG}-${BUILD_4BOARD}.srec
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar/debug/bl31.bin ]; then
            cp build/rcar/debug/bl31.srec   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/debug/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp build/rcar/debug/bl2.srec   ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/debug/bl2.bin    ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp tools/renesas/rcar_layout_create/bootparam_sa0.srec    ${OUTDIR_ATF}/bootparam_sa0_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp tools/renesas/rcar_layout_create/cert_header_sa6.srec    ${OUTDIR_ATF}/cert_header_sa6_${BUILD_CFG}-${BUILD_4BOARD}.srec
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_2
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_2
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;
	
	1)
        echo "Create output folder for TP-001"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_1"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar/release/bl31.bin ]; then
            cp build/rcar/release/bl31.srec   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp build/rcar/release/bl2.srec   ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/release/bl2.bin    ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp tools/renesas/rcar_layout_create/bootparam_sa0.srec    ${OUTDIR_ATF}/bootparam_sa0_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp tools/renesas/rcar_layout_create/cert_header_sa6.srec    ${OUTDIR_ATF}/cert_header_sa6_${BUILD_CFG}-${BUILD_4BOARD}.srec
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar/debug/bl31.bin ]; then
            cp build/rcar/debug/bl31.srec   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/debug/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp build/rcar/debug/bl2.srec   ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar/debug/bl2.bin    ${OUTDIR_ATF}/bl2_${BUILD_CFG}-${BUILD_4BOARD}.bin
            cp tools/renesas/rcar_layout_create/bootparam_sa0.srec    ${OUTDIR_ATF}/bootparam_sa0_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp tools/renesas/rcar_layout_create/cert_header_sa6.srec    ${OUTDIR_ATF}/cert_header_sa6_${BUILD_CFG}-${BUILD_4BOARD}.srec
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_1
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_1
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        "0")
        echo "Create output folder"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_0"
	        echo "Set OUTDIR to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    cp build/rcar_gen4/release/bl31/bl31.elf ${binary_local_path}/release/bl31_${BUILD_CFG}.elf
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    cp build/rcar_gen4/debug/bl31/bl31.elf ${binary_local_path}/debug/bl31_${BUILD_CFG}.elf
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_0
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_0
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        *)
        echo "Invalid index TP"
    esac

}


###This is function to use check cases before burning and booting processs####
#check any condition, below is to check secure or normal boot based on digit[7] of burnmode variable of each test case
function check_test_case(){
    is_secure_boot=$1
    TA_ENC=$2
    if [ ${is_secure_boot} -eq 1 ]; then
        echo "Start to prepare for secure boot"
		sshpass -p raspberry ssh pi@${PI_IPADDR} "cd ${REMOTE_DIR} && ./auto_ctrl.py ${I2C_ADDR} on && ./auto_ctrl.py set ${I2C_ADDR} 11 out 0 && exit"
		if [ ${TA_ENC} -eq 1 ];then
			echo "TA encryption = YES"
		else
			echo "TA_encryption = NO"
		fi
    else
        echo "Normal boot"
		sshpass -p raspberry ssh pi@${PI_IPADDR} "cd ${REMOTE_DIR} && ./auto_ctrl.py ${I2C_ADDR} on && ./auto_ctrl.py set ${I2C_ADDR} 11 out 1 && exit"
    fi
}


function burn_reboot_board_exec_test(){
    # Read CFG, TP, testid, burnmode to burn image and reboot board to run test

    echo "==========Start burn_reboot_board_exec_test==========="

    CFG=$1
    TP=$2
    burn_mode=$3
    test_sheet=$4
    test_id=$5
    digit[0]="${burn_mode:0:1}" #TA_encrypt mode
    digit[1]="${burn_mode:1:1}" #burn for uboot
    digit[2]="${burn_mode:2:1}" #burn for sa0
    digit[3]="${burn_mode:3:1}" #burn for sa6
    digit[4]="${burn_mode:4:1}" #burn for BL31
    digit[5]="${burn_mode:5:1}" #burn for BL2
    digit[6]="${burn_mode:6:1}" #burn for optee_os
    digit[7]="${burn_mode:7:1}" #type of modes: secure boot: 1 or normal boot: 0
    i=0

    echo "TP: $TP"
    echo "CFG: $CFG"
    echo "burn_mode: $burn_mode"
    echo "test_sheet: $test_sheet"
    echo "test_id: $test_id"

    while IFS= read -r line
    do
        arr_first[$i]=$line
        eval "arr=(${arr_first[$i]})"
        if [ $test_id = ${arr[0]} ]; then
            if [[ $test_sheet = ${arr[1]} && "$CFG" -eq "${arr[2]}" && "$TP -eq ${arr[3]}" ]]; then
                sshpass -p raspberry ssh pi@${PI_IPADDR} "cd ${REMOTE_DIR} && ./auto_ctrl.py ${I2C_ADDR} on && ./auto_ctrl.py ${I2C_ADDR} monitor && exit"
                if [ $i -gt 0 ]; then
                    Pre_array[$i-1]=${arr_first[$i-1]}
                    echo "Pre_array: ${Pre_array[$i-1]}"
                    eval "Pre_array=(${Pre_array[$i-1]})"
                    PRE_TEST_SHEET=${Pre_array[1]}
                    PRE_CFG=${Pre_array[2]}
                    PRE_TP=${Pre_array[3]}
                    if [[ $TP -eq $PRE_TP && $CFG -eq $PRE_CFG ]]; then
                        echo "Not burn this case"
                    else
                        if [ ${digit[7]} -eq 1 ]; then
                            echo "Start all image for secure boot"
                            if [ "${LSI_VARIANT}" = "m3" ]; then
                                cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . all
                            elif [ "${LSI_VARIANT}" = "e3" ]; then
                                cd "${binary_local_path}" && python3 ./ipl_burning.py e3_4x512 ${SERIAL_PORT} . . all
                            fi
                        elif [ ${digit[7]} -eq 0 ]; then
                       #  
                       #     echo "normal boot or others"
                       #     if [ ${digit[0]} -eq 1 ];then
                       #         echo "Start burn Uboot"
                       #         cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . uboot
                       #     fi
                       #     if [ ${digit[1]} -eq 1 ];then
                       #         echo "Start burn SA0"
                       #         cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . param
                       #     fi
                       #     if [ ${digit[2]} -eq 1 ];then
                       #         echo "Start burn SA6"
                       #         cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . cert6
                       #     fi
                       #     if [ ${digit[3]} -eq 1 ];then
                       #         echo "Start burn BL31"
                       #         cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . bl31
                       #     fi
                       #     if [ ${digit[4]} -eq 1 ];then
                       #         echo "Start burn BL2"
                       #         cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . bl2
                       #     fi
                       # 
                            if [ ${digit[6]} -eq 1 ]; then
                                echo "Start burn all"
                                if [ "${LSI_VARIANT}" = "m3" ]; then
                                    cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . all
                                elif [ "${LSI_VARIANT}" = "e3" ]; then
                                    cd "${binary_local_path}" && python3 ./ipl_burning.py e3_4x512 ${SERIAL_PORT} . . all
                                fi
                            fi
                        fi
                    fi
                else
                    echo "First burn - burn all"
                    if [ "${LSI_VARIANT}" = "m3" ]; then
                        cd "${binary_local_path}" && python3 ./ipl_burning.py m3 ${SERIAL_PORT} . . all
                    elif [ "${LSI_VARIANT}" = "e3" ]; then
                        cd "${binary_local_path}" && python3 ./ipl_burning.py e3_4x512 ${SERIAL_PORT} . . all
                    fi
                fi
                echo "Reboot board"
                cd ${PROJECT_SOURCE_DIR}/gen3/scripts && python3 reboot_command_ipl.py
            fi
	else
            i=$(($i+1))
        fi

    done < "$PROJECT_BINARY_DIR/EXTRACT_TEST_FEATURE_LIST.txt"

    echo "==========End burn_reboot_board_exec_test==========="

}


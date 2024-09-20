#!/bin/bash

if [ -z "$PROJECT_BINARY_DIR" ];then
    export PROJECT_BINARY_DIR=$PROJECT_BINARY_DIR
	echo "PROJECT_BINARY_DIR=$PROJECT_BINARY_DIR"
fi
source ${PROJECT_BINARY_DIR}/optee_it_env.sh

############################################################################
# Function definition
############################################################################
unset LD_LIBRARY_PATH

#==================Build atf =============#
atf_configs_gen4=(
    ""
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0" #1
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=1" #2
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=0" #3
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=10" #4
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=20" #5
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=30" #6
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=40" #7
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=0 LOG_LEVEL=50" #8
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=1 LOG_LEVEL=20" #9
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=1 LOG_LEVEL=20" #10
	"LSI=S4 CTX_INCLUDE_AARCH32_REGS=0 DEBUG=1 LOG_LEVEL=40" #11
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
    BUILD_CFG=$1
    TP=$2

    ##---------------------------- Build ATF -------------------------##
    cd "${ATF_SRC_DIR}"

    echo "Build with cfg number: $BUILD_CFG (${atf_configs_gen4[$BUILD_CFG]})"
    make distclean
    make clean_srecord PLAT=rcar_gen4 SPD=opteed MBEDTLS_COMMON_MK=1 ${atf_configs_gen4[$BUILD_CFG]}
    make bl31 rcar_srecord PLAT=rcar_gen4 SPD=opteed MBEDTLS_COMMON_MK=1 ${atf_configs_gen4[$BUILD_CFG]}

    ##---------------------Copy ATF output ---------------------------##
    case "$TP" in
        2)
        echo "Create output folder for TP-002"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_2"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
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

        25)
        echo "Create output folder for TP-0025"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_25"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_25
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_25
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        28)
        echo "Create output folder for TP-0028"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_28"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_28
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_28
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        27)
        echo "Create output folder for TP-0027"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_27"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_27
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_27
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        29)
        echo "Create output folder for TP-0029"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_29"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_29
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_29
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        26)
        echo "Create output folder for TP-0026"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_26"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_26
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_26
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        210)
        echo "Create output folder for TP-00210"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_210"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_210
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_210
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        211)
        echo "Create output folder for TP-00211"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_211"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_211
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_211
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        22)
        echo "Create output folder for TP-0022"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_22"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_22
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_22
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        23)
        echo "Create output folder for TP-0023"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_23"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_23
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_23
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        216)
        echo "Create output folder for TP-00216"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_216"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_216
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_216
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        219)
        echo "Create output folder for TP-00219"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_219"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_219
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_219
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        218)
        echo "Create output folder for TP-00218"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_218"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_218
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_218
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        213)
        echo "Create output folder for TP-00213"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_213"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_213
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_213
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        214)
        echo "Create output folder for TP-00214"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_214"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_214
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_214
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        212)
        echo "Create output folder for TP-00212"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_212"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_212
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_212
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

	20)
        echo "Create output folder for TP-0020"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_20"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_20
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_20
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        10)
        echo "Create output folder for TP-010"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_10"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
	        mkdir -p ${OUTDIR_ATF}
        fi

        if [ -f build/rcar_gen4/release/bl31.bin ]; then
            cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -release- output to: ${OUTDIR_ATF}"
        elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
            cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
            cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_10
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_10
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

        4)
        echo "Create output folder for TP-004"
        if [[ ! -d ${OUTDIR_ATF} ]]; then
	        OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_4"
	        echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
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
            echo "Copy -debug- output to: ${OUTDIR_ATF}"
        fi
        ls -l ${OUTDIR_ATF}/*
        mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_4
        cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_4
        echo "-----------------------------"
        echo "Finish building and copy:"
        echo "      Build_Configuration/TP: "${BUILD_CFG} ${TP}
        echo "-----------------------------"
        ;;

	7)
	echo "Create output folder for TP-07"
	if [[ ! -d ${OUTDIR_ATF} ]]; then
		OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_7"
		echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
		mkdir -p ${OUTDIR_ATF}
	fi

	if [ -f build/rcar_gen4/release/bl31.bin ]; then
	    cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
	    cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    echo "Copy -release- output to: ${OUTDIR_ATF}"
	elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
	    cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
	    cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    echo "Copy -debug- output to: ${OUTDIR_ATF}"
	fi
	ls -l ${OUTDIR_ATF}/*
	mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_7
	cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_7
	echo "--------------------------------"
	echo "Finish building and copy:"
	echo "	    Build_Configuration/TP:    "${BUILD_CFG} ${TP}
	echo "--------------------------------"
	;;

	7_8)
	echo "Create output folder for TP-07_8"
	if [[ ! -d ${OUTDIR_ATF} ]]; then
		OUTDIR_ATF="${CMAKE_CURRENT_BINARY_DIR}/out/atf_tp_7_8"
		echo "Set OUTDIR 1 to: ${OUTDIR_ATF}"
		mkdir -p ${OUTDIR_ATF}
	fi

	if [ -f build/rcar_gen4/release/bl31.bin ]; then
	    cp build/rcar_gen4/release/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
	    cp build/rcar_gen4/release/bl31.bin   ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    echo "Copy -release- output to: ${OUTDIR_ATF}"
	elif [ -f build/rcar_gen4/debug/bl31.bin ]; then
	    cp build/rcar_gen4/debug/bl31.srec  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.srec
	    cp build/rcar_gen4/debug/bl31.bin  ${OUTDIR_ATF}/bl31_${BUILD_CFG}-${BUILD_4BOARD}.bin
	    echo "Copy -debug- output to: ${OUTDIR_ATF}"
	fi
	ls -l ${OUTDIR_ATF}/*
	mkdir -p $BUILT_RESULT_BINARY_DIR/Result_tp_7_8
	cp -r ${OUTDIR_ATF}/* ${BUILT_RESULT_BINARY_DIR}/Result_tp_7_8
	echo "--------------------------------"
	echo "Finish building and copy:"
	echo "      Build_Configuration/TP:    "${BUILD_CFG} ${TP}
	echo "--------------------------------"
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

function build_el1(){
    # Build SMC Dummy EL1 for TP2
    echo "BUILD DUMMY EL1"
    TP=$2

    ## ------------------ Pre-built setting -------------------##
    unset LDFLAGS
    unset AS
    unset LD
    set -x

    cd ${SMC_DUMMY_SRC_DIR}

    make clean
    make

    echo "Create output folder for DUMMY EL1"
    if [[ ! -d ${OUTDIR_EL1} ]]; then
        OUTDIR_EL1="${CMAKE_CURRENT_BINARY_DIR}/out/dummy_el1"
        echo "Set OUTDIR to: ${OUTDIR_EL1}"
	mkdir -p ${OUTDIR_EL1}
    fi
    if [ -f build/default/bin/dummy_el1.srec ]; then
        cp build/default/bin/dummy_el1.srec  ${OUTDIR_EL1}/dummy_el1-${BUILD_4BOARD}-$TP.srec
        cp build/default/bin/dummy_el1.dump  ${OUTDIR_EL1}/dummy_el1-${BUILD_4BOARD}-$TP.dump
        ls -l ${OUTDIR_EL1}
        echo "Copy -release- output to: ${OUTDIR_EL1}"
    fi

    # copy output
    echo "Copy DUMMY EL1 to binary dir"
    chmod 777 -R ${OUTDIR_EL1}/*
    cp -r ${OUTDIR_EL1}/* ${binary_local_path}
}


###This is function to use check cases before burning and booting processs####
#check any condition, below is to check secure or normal boot based on digit[7] of burnmode variable of each test case
function check_test_case(){
    is_secure_boot=$1
    TA_ENC=$2
    if [ ${is_secure_boot} -eq 1 ]; then
        echo "Start to prepare for secure boot"
	# Change mode to Secure Boot
        ${CPLD_EXE} -w S4 ${CPLD_SERIAL_NUM} 0x0008 0x00010081006120A4 0x0024 0x01
        if [ ${TA_ENC} -eq 1 ];then
            echo "TA encryption = YES"
        else
            echo "TA_encryption = NO"
        fi
    else
        echo "Normal boot"
	# Change mode to normal boot
        ${CPLD_EXE} -w S4 ${CPLD_SERIAL_NUM} 0x0008 0x0001008100612084 0x0024 0x01
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
    digit[8]="${burn_mode:8:1}" #type of modes: ca55 loader: 1 or normal: 0
    i=0

    echo "TP: $TP"
    echo "CFG: $CFG"
    echo "burn_mode: $burn_mode"
    echo "test_sheet: $test_sheet"
    echo "test_id: $test_id"

    while IFS= read -r line  # Read each line from EXTRACT_TEST_FEATURE_LIST.txt file
    do
        arr_first[$i]=$line
        eval "arr=(${arr_first[$i]})"

	# Check test config match which line in EXTRACT_TEST_FEATURE_LIST.txt file
        if [ $test_id = ${arr[0]} ]; then
	    # Check Test config match with line
	    if [[ $test_sheet = ${arr[1]} && "$CFG" -eq "${arr[2]}" && "$TP -eq ${arr[3]}" ]]; then
                # switch to download mode
		${CPLD_EXE} -w S4 ${CPLD_SERIAL_NUM} 0x0008 0x00010081005120BE 0x0024 0x01

		# Check if not first burn
		if [ $i -gt 0 ]; then
                    Pre_array[$i-1]=${arr_first[$i-1]}
                    echo "Pre_array: ${Pre_array[$i-1]}"
                    eval "Pre_array=(${Pre_array[$i-1]})"
                    PRE_TEST_SHEET=${Pre_array[1]}
                    PRE_CFG=${Pre_array[2]}
                    PRE_TP=${Pre_array[3]}

		    # If TP and CFG not change: not burn
		    if [[ $TP -eq $PRE_TP && $CFG -eq $PRE_CFG ]]; then
                        echo "Not burn this case"

                    else
                        #---- Secure boot mode----#
                        if [ ${digit[7]} -eq 1 ]; then
			    echo "Step 7"
                            echo "Start all image for secure boot"
                            if [ "${LSI_VARIANT}" = "s4" ]; then
			       echo "Step 8"
                               cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf ${SERIAL_PORT} . . all
                        fi

			#---- Normal boot mode---#
                        elif [ ${digit[7]} -eq 0 ]; then
			#---- CA55 IPL mode---#
			    if [ ${digit[8]} -eq 1 ]; then
				echo "Copy CA55 IPL infinity loop version"
				cp /shsv/Android/SoftIP/sec_bsp/build_info/S4/ATF/ca55_loader.srec ${binary_local_path}/ca55_loader.srec
			    #---- TO DO : Edit burn mode later ----#
                            if [ ${digit[6]} -eq 1 ]; then
                                echo "TO Do : Edit burn mode later"
                                if [ "${LSI_VARIANT}" = "s4" ]; then
                                    if [ "$TP" = "2" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp2 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "25" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp25 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "28" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp28 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "27" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp27 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "29" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp29 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "26" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp26 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "210" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp210 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "211" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp211 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "22" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp22 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "23" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp23 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "216" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp216 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "219" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp219 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "218" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp218 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "213" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp213 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "214" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp214 ${SERIAL_PORT} . . all
                                    elif [ "$TP" = "212" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp212 ${SERIAL_PORT} . . all
				    elif [ "$TP" = "20" ]; then # TP2 : We need burn el1 instead of uboot
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp20 ${SERIAL_PORT} . . all
                                    else
                                        cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf ${SERIAL_PORT} . . all
                                    fi
                                fi
                            fi
                        fi
                    fi
		fi	
		#----------Burn First test case ------#
	    	else
		    if [ ${digit[8]} -eq 1 ]; then
		    echo "Copy CA55 IPL infinity loop version"
		    cp /shsv/Android/SoftIP/sec_bsp/build_info/S4/ATF/ca55_loader.srec ${binary_local_path}/ca55_loader.srec
                    echo "First burn - burn all"
                    if [ "${LSI_VARIANT}" = "s4" ]; then
                        if [ "$TP" = "2" ]; then
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp2 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "25" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp25 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "28" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp28 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "27" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp27 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "29" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp29 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "26" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp26 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "210" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp210 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "211" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp211 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "22" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp22 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "23" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp23 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "216" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp216 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "219" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp219 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "218" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp218 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "213" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp213 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "214" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp214 ${SERIAL_PORT} . . all
                        elif [ "$TP" = "212" ]; then # TP2 : We need burn el1 instead of uboot
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp212 ${SERIAL_PORT} . . all
			elif [ "$TP" = "20" ]; then # TP2 : We need burn el1 instead of uboot
    			    cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf_tp20 ${SERIAL_PORT} . . all                        
		    	else
                            cd "${binary_local_path}" && python3 ./ipl_burning.py s4_atf ${SERIAL_PORT} . . all
                        fi
                    fi
		    fi
                fi	
                echo "Reboot board"
                if [ "$TP" = "10" ]; then # TP10 : we need to change dtb to Disable cpu-idle behavior on Linux
                    echo "Change dtb to Disable cpu-idle behavior on Linux"
                    cp ${root}/r8a779f0-spider.dtb.tp10 ${root}/r8a779f0-spider.dtb
	    	elif ["$TP" = "8" ]; then
                    cp ${root}/r8a779f0-spider.dtb.tp8 ${root}/r8a779f0-spider.dtb
		else
		    cp ${root}/r8a779f0-spider.dtb.normal ${root}/r8a779f0-spider.dtb
                fi
		if [ "$CFG" = "9" ]; then
		cp ${binary_local_path}/debug/bl31_${BUILD_CFG}.elf ${PROJECT_BINARY_DIR}/arm-trusted-firmware/build/rcar_gen4/debug/bl31/bl31.elf
		rm ${binary_local_path}/debug/bl31_${BUILD_CFG}.elf 
	else
		cp ${binary_local_path}/release/bl31_${BUILD_CFG}.elf ${PROJECT_BINARY_DIR}/arm-trusted-firmware/build/rcar_gen4/release/bl31/bl31.elf
		rm ${binary_local_path}/release/bl31_${BUILD_CFG}.elf
		fi	
                cd ${PLATFORM_SCRIPTS} && python3 reboot_command_ipl.py # Reboot
            fi
    	else
            i=$(($i+1))
        fi

    done < "$PROJECT_BINARY_DIR/EXTRACT_TEST_FEATURE_LIST.txt"

    echo "==========End burn_reboot_board_exec_test==========="
}


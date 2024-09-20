#!/bin/bash
export SDKROOT=/shsv/Android/SoftIP/10_DienPham/sdk_v5_9_0
export CROSS_COMPILE=${SDKROOT}/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-
export CROSS_COMPILE64=${CROSS_COMPILE}
export PREPARED_BIN_DIR=${CMAKE_CURRENT_BINARY_DIR}
export TA_DEV_KIT_DIR=${OPTEE_OS_SRC_DIR}/out/arm-plat-rcar/export-ta_arm64
export CROSS_COMPILE_HOST=${SDKROOT}/sysroots/aarch64-poky-linux/usr/bin
export TOOLCHAIN_VERSION=2.4.3
unset LD_LIBRARY_PATH
export binary_local_path
export BINARY_DIR=${PREPARED_BIN_DIR}
export PATH_TO_FILE_MOT=${BINARY_DIR}
export PATH_TO_IPL=${BINARY_DIR}

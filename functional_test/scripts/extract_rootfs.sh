#!/bin/bash

echo ">> Extract & prepare rootfs"

CMAKE_CURRENT_BINARY_DIR=$1
ROOTFS=$2
binary_local_path=${CMAKE_CURRENT_BINARY_DIR}/binaries_dir

if [ ! -e "${ROOTFS}/Image" ]; then
    mkdir -p "${ROOTFS}" && chmod 777 "${ROOTFS}"
    tar xf ${binary_local_path}/rcar-image-gateway-spider.tar.bz2 -C "${ROOTFS}"
    cp -rf ${binary_local_path}/Image "${ROOTFS}"
    cp -rf ${binary_local_path}/r8a779f0-spider.dtb "${ROOTFS}"
    echo "Content of ${ROOTFS}:"
    ls -l "${ROOTFS}"
fi
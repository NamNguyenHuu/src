#!/bin/bash
TEST_ID=$1
echo "Test_ID =${TEST_ID}"

case "$TEST_ID" in
    "TC47")
        echo "TC47"
    ;;
    "TC56")
        echo 0 >/sys/devices/system/cpu/cpu1/online
        echo 0 >/sys/devices/system/cpu/cpu2/online
        echo 0 >/sys/devices/system/cpu/cpu3/online
        echo 0 >/sys/devices/system/cpu/cpu4/online
        echo 0 >/sys/devices/system/cpu/cpu5/online
        echo 0 >/sys/devices/system/cpu/cpu6/online
        echo 0 >/sys/devices/system/cpu/cpu7/online
        echo "TC56"
    ;;
    *)
        echo 0
    ;;
esac

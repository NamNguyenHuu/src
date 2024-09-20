#######################################################################################################################
# Import from standard libraries
#######################################################################################################################
import serial
import sys
import os
import subprocess
import time
serial_handle = ''
start_time = ''

#######################################################################################################################
# SerialHelper
# Serial helper to wait partern and send command line to board
#######################################################################################################################
class SerialHelper(serial.Serial):
    def wait(self, pattern, exception_patterns=[], time_out = 120, enable_log = True, allow_timeout = False):
        end_time = float(time.time() + time_out)
        line = ""
        while time.time() < end_time:
            bytes_to_read = self.in_waiting
            if bytes_to_read:
                string = self.read()
                string = string.decode("utf-8", "ignore")
                line += string
                if "\n" in string:
                    end_time = float(time.time() + time_out)
                    if enable_log:
                        print(line, end ="")
                    sys.stdout.flush()
                    for exception_pattern in exception_patterns:
                        if exception_pattern in line:
                            if "mount: Can't mount" in line:
                                return CIError.NFS_CANNOT_MOUNT.value
                            else:
                                return CIError.UNKNOWN_ERROR.value
                    line = ""
                if pattern in line:
                    print(line, end ="")
                    sys.stdout.flush()
                    return 0
        if allow_timeout:
            return CIError.SERIAL_TIMEOUT.value
        else:
            raise Exception("Serial Timeout error while waiting for " + pattern + "!!!")

    def send(self, string, delay = 0.1):
        time.sleep(delay)
        self.write((string + "\r").encode())

    def wait_return(self, time_out = 20):
        end_time = float(time.time() + time_out)
        line = ""
        while time.time() < end_time:
            bytes_to_read = self.in_waiting
            if bytes_to_read:
                string = self.read()
                string = string.decode("utf-8", "ignore")
                line += string
                if "\n" in string:
                    print(line, end ="")
                    sys.stdout.flush()
                    return line

        return CIError.SERIAL_TIMEOUT.value

    # wait a line by pattern, then send next_command if any, timeout 10 in minutes
    def wait_send(self, pattern, delay_send=0, cmd_to_send="NONE", time_out=600):
        buffer = ""
        end_time = int(time.time()) + time_out
        while int(time.time()) < end_time:
            bytes_to_read = self.inWaiting()
            if bytes_to_read:
                line = self.read(bytes_to_read).decode('ISO-8859-1')
                buffer += line
                sys.stdout.write(line)
                sys.stdout.flush()
                if pattern in buffer:
                    time.sleep(delay_send)
                    if cmd_to_send != "NONE":
                        str_send = cmd_to_send + "\r"
                        self.write(str_send.encode())
                    return 0
        return 255

#######################################################################################################################
# SerialInit
# Checking and init serial port
#######################################################################################################################
def SerialInit(port, baudrate):
    print("=== Checking serial port ===")
    sys.stdout.flush()
    # Reset USB connection with target board if required (USB controller lockup in condor/condorI boards)
    if os.getenv("USB_MOUNT_POINT") is not None:
        print("=== USB comms reset ===")
        sys.stdout.flush()
        usb_mount_point  =  os.getenv('USB_MOUNT_POINT')
        # Soft disconnect and then connect attached USB serial of the target board.
        ret = subprocess.call( "echo -n '%s' > /sys/bus/usb/drivers/usb/unbind ; sleep 3 ; echo -n '%s' > /sys/bus/usb/drivers/usb/bind"
                               %(usb_mount_point, usb_mount_point), shell=True)
        time.sleep(3)

    # SERIAL_MOUNT_POINT is the variable for RVC board
    elif os.getenv("CP210X_MOUNT_POINT") is not None:
        print("=== Serial port reset ===")
        sys.stdout.flush()
        cp210x_mount_point =  os.getenv('CP210X_MOUNT_POINT')
        # Soft disconnect and then connect attached USB  of the target board.
        ret = subprocess.call( "echo -n '%s' > /sys/bus/usb/drivers/cp210x/unbind ; sleep 3 ; echo -n '%s' > /sys/bus/usb/drivers/cp210x/bind"
                               %(cp210x_mount_point, cp210x_mount_point), shell=True)
        time.sleep(3)
    try:
        serial_handle = SerialHelper(port = port, baudrate = baudrate, bytesize = serial.EIGHTBITS, \
            parity = serial.PARITY_NONE, stopbits = serial.STOPBITS_ONE)
        if not serial_handle.isOpen():
            serial_handle.open()
            print("Open port %s successfully" %(port))
        else:
            print("Serial port %s is already open" %(port))
            serial_handle.reset_input_buffer()
            serial_handle.reset_output_buffer()
            serial_handle.flush()
    except Exception as e:
        str_to_print = "Can not open port: " + str(e)
        LogError(CIError.SERIAL_CANNOT_OPEN.name, str_to_print)
        sys.exit(CIError.SERIAL_CANNOT_OPEN.value)
    sys.stdout.flush()

    return serial_handle

## Get environment variables from: atf_it_target_test.sh
HOST_IP = os.environ["HOST_IP"]
BOARD_IP = os.environ["BOARD_IP"]
ROOTFS = os.environ["ROOTFS"]
PREFIX_ROOTFS = os.path.basename(ROOTFS)
SERIAL_PORT = os.environ["SERIAL_PORT"]
RUNNER_BOARD = os.environ["RUNNER_BOARD"]
COMMAND = os.environ.get("COMMAND")
TEST_COMMAND = os.environ.get("TEST_COMMAND")
CPLD_BOARD = os.environ['LSI_VARIANT'].upper()
CPLD_EXE = os.environ['CPLD_EXE']
CPLD_SERIAL_NUM = os.environ['CPLD_SERIAL_NUM']
TP = os.environ["TP"]
#
BUILD_CFG = os.environ["BUILD_CFG"]
PROJECT_BINARY_DIR = os.environ["PROJECT_BINARY_DIR"]
PROJECT_SOURCE_DIR = os.environ["PROJECT_SOURCE_DIR"]

# cmd to Reboot board
# Prepare a reboot cmd as below: sudo  cpld-control-1.7.1 -w S4 001141 0x0008 0x00010080006120A8 0x0024 0x01
reboot_cmd = CPLD_EXE + ' -w ' + CPLD_BOARD + ' ' + CPLD_SERIAL_NUM + ' ' + '0x0008 0x00010081005120A8 0x0024 0x01'
print("Print rebootcmd: " + reboot_cmd)

if TP == "2" or TP == "25" or TP == "28" or TP == "27" or TP == "29" or TP == "26" or TP == "210" or TP == "211" or TP == "22" or TP == "23" or TP == "216" or TP == "219" or TP == "218" or TP == "213" or TP == "214" or TP == "212":
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("TP has finished.")

elif TP == "20":
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("TP has finished.")
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "Boot9_6.cmm")
    os.system(f"touch my_append.txt")
    os.system(f"{trace32} -c {usb_port} -s {data_script}") 
    with open("my_append.txt", "r") as file:
        content = file.read()
        print(content)
    file.close()
    os.system(f"rm my_append.txt")
    handle.wait("END_DUMP_REGISTER")

elif TP == "4":
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("Dummy RTOS Program boot end")
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "Logging.cmm")
    os.system(f"{trace32} -c {usb_port} -s {data_script}")
    handle.wait("RAM Configuration:")
elif BUILD_CFG == "9": 
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("Dummy RTOS Program boot end")
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "CANARY.cmm")
    os.system(f"{trace32} -c {usb_port} -s {data_script}")
    handle.wait("BACKTRACE: END: __stack_chk_fail")
elif BUILD_CFG == "10": 
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("Dummy RTOS Program boot end")
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "CANARY_normal.cmm")
    os.system(f"{trace32} -c {usb_port} -s {data_script}")
    handle.wait_send("Hit any key to stop autoboot: ", 0.3, " ")
    handle.wait_send("=> ", 0.3, "setenv serverip " + HOST_IP)
    handle.wait_send("=> ", 0.3, "setenv ipaddr " + BOARD_IP)
    handle.wait_send("=> ", 0.3, "setenv ethaddr " + "f{eth_add}")
    handle.wait_send("=> ", 0.3, "ping " + HOST_IP)

    handle.wait_send(
        "=> ", 0.3, "setenv bootargs 'rw root=/dev/nfs nfsroot=192.168.20.30:/tftpboot/gen4_ci_rootfs_atf/S4,nfsvers=3 ip=192.168.20.200:::::tsn0 cma=560M'",
    )
    handle.wait_send(
        "=> ", 0.3, "setenv bootcmd 'tftp 0x48080000 " + ROOTFS + "/Image; tftp 0x48000000 " + ROOTFS + "/r8a779f0-spider.dtb; booti 0x48080000 - 0x48000000'",
    )
    handle.wait_send("=> ", 0.3, "saveenv")
    handle.wait_send("=> ", 0.3, "run bootcmd")
    handle.wait_send("spider login: ", 0.3, "root")
    handle.wait_send("root@spider:~#", 0.3, COMMAND)
    handle.wait_send("root@spider:~#", 0.3, "" + f"{TEST_COMMAND}")
elif BUILD_CFG == "11": 
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait("Dummy RTOS Program boot end")
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "Boot1-4.cmm")
    os.system(f"touch my_append.txt")
    os.system(f"{trace32} -c {usb_port} -s {data_script}")
    handle.wait("INFO:    SPSR = 0x3c5")
    with open("my_append.txt", "r") as file:
        content = file.read()
        print(content)
    file.close()
    os.system(f"rm my_append.txt")
    handle.wait("END_DUMP_REGISTER")

else:
    BAUDRATE = 1843200
    handle = SerialInit(SERIAL_PORT, BAUDRATE)
    subprocess.call(reboot_cmd, shell=True)
    handle.wait_send("Hit any key to stop autoboot: ", 0.3, " ")
    handle.wait_send("=> ", 0.3, "setenv serverip " + HOST_IP)
    handle.wait_send("=> ", 0.3, "setenv ipaddr " + BOARD_IP)
    handle.wait_send("=> ", 0.3, "setenv ethaddr " + "f{eth_add}")
    handle.wait_send("=> ", 0.3, "ping " + HOST_IP)

    handle.wait_send(
        "=> ", 0.3, "setenv bootargs 'rw root=/dev/nfs nfsroot=192.168.20.30:/tftpboot/gen4_ci_rootfs_atf/S4,nfsvers=3 ip=192.168.20.200:::::tsn0 cma=560M'",
    )
    handle.wait_send(
        "=> ", 0.3, "setenv bootcmd 'tftp 0x48080000 " + ROOTFS + "/Image; tftp 0x48000000 " + ROOTFS + "/r8a779f0-spider.dtb; booti 0x48080000 - 0x48000000'",
    )
    handle.wait_send("=> ", 0.3, "saveenv")
    handle.wait_send("=> ", 0.3, "run bootcmd")
    handle.wait_send("spider login: ", 0.3, "root")
    handle.wait_send("root@spider:~#", 0.3, COMMAND)
    handle.wait_send("root@spider:~#", 0.3, "" + f"{TEST_COMMAND}")

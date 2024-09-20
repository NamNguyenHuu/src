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
def SerialInit(port):
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
        BAUDRATE = 115200
        serial_handle = SerialHelper(port = port, baudrate = BAUDRATE, bytesize = serial.EIGHTBITS,
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
TP = os.environ["TP"]
#
BUILD_CFG = os.environ["BUILD_CFG"]
PROJECT_BINARY_DIR = os.environ["PROJECT_BINARY_DIR"]
PROJECT_SOURCE_DIR = os.environ["PROJECT_SOURCE_DIR"]

handle = SerialInit(SERIAL_PORT)
password = "raspberry"
pi_ipaddr = "192.168.20.95"
remote_dir = "/home/pi/01_featbox_software"
i2c_addr = os.environ["I2C_ADDR"]
eth_add = "2E:09:0A:03:9C:56"


ssh_command = (
    f"sshpass -p '{password}' ssh pi@{pi_ipaddr} "
    f"'cd {remote_dir} && ./auto_ctrl.py {i2c_addr} uboot'"
)

if BUILD_CFG == "9":
        # Set boot args e.g. setenv bootargs 'rw root=/dev/nfs nfsroot=192.168.0.1:/home/renesas/work/export ip=192.168.0.20:::::tsn0 ignore_loglevel cma=256M'"
            # handle.wait_send("=> ", 0.3,"setenv bootargs 'rw root=/dev/nfs nfsroot=" + HOST_IP + ":" + "/tftpboot/gen3_ci_roofts/M3" + " ip=" + BOARD_IP + "'")
    ret = subprocess.call(ssh_command, shell=True)
    handle.wait("ERROR:   System WDT overflow, occurred address is 0xe631336c")

elif BUILD_CFG == "10":
    ret = subprocess.call(ssh_command, shell=True)
    handle.wait("NOTICE:  BL2: Booting BL31")

else:
        # Set boot args e.g. setenv bootargs 'rw root=/dev/nfs nfsroot=192.168.0.1:/home/renesas/work/export ip=192.168.0.20:::::tsn0 ignore_loglevel cma=256M'"
            # handle.wait_send("=> ", 0.3,"setenv bootargs 'rw root=/dev/nfs nfsroot=" + HOST_IP + ":" + "/tftpboot/gen3_ci_roofts/M3" + " ip=" + BOARD_IP + "'")
    ret = subprocess.call(ssh_command, shell=True)
    handle.wait_send("Hit any key to stop autoboot: ", 0.3, " ")
    handle.wait_send("=> ", 0.3, "setenv serverip " + HOST_IP)
    handle.wait_send("=> ", 0.3, "setenv ipaddr " + BOARD_IP)
    handle.wait_send("=> ", 0.3, "setenv ethaddr " + "f{eth_add}")
    handle.wait_send("=> ", 0.3, "ping " + HOST_IP)


    handle.wait_send(
        "=> ",
        0.3,
        "setenv bootargs 'rw root=/dev/nfs nfsroot=192.168.20.30:/tftpboot/baohua/M3,nfsvers=3 ip=192.168.20.161'",
    )
    handle.wait_send(
        "=> ",
        0.3,
        "setenv bootcmd 'tftp 0x48080000 "
        + ROOTFS
        + "/Image; tftp 0x48000000 "
        + ROOTFS
        + "/r8a77961-salvator-xs.dtb; booti 0x48080000 - 0x48000000'",
    )
    handle.wait_send("=> ", 0.3, "saveenv")
    handle.wait_send("=> ", 0.3, "run bootcmd")
    handle.wait_send("salvator-x login: ", 0.3, "root")
    handle.wait_send("root@salvator-x:~#", 0.3, COMMAND)
    handle.wait_send("root@salvator-x:~#", 0.3, "" + f"{TEST_COMMAND}")




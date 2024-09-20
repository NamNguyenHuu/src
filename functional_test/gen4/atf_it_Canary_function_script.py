import os
import sys
import subprocess
import shutil
from helpers import test_with_normal_boot


test_defined_table = [
    ["TC1", "Canary_function", "9", "0", "111111101"],
    ["TC2", "Canary_function", "10", "0", "111111101"],
]


def test_case_execute(
    TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
):
    if TEST_ID in [row[0] for row in test_defined_table]:
        test_with_normal_boot(
            TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
        )
    else:
        raise ValueError("No test case")


if __name__ == "__main__":
    TEST_SHEET = sys.argv[1]
    TEST_ID = sys.argv[2]
    PROJECT_SOURCE_DIR = sys.argv[3]
    PROJECT_BINARY_DIR = sys.argv[4]

    subprocess.run(
        [f"bash -c 'source {PROJECT_BINARY_DIR}/atf_it_env.sh && env > env_file'"],
        shell=True,
    )

    env_file_path = "env_file"
    with open(env_file_path, "r") as env_file:
        for line in env_file:
            # Check if the line has the expected format
            if "=" in line:
                key, value = line.strip().split("=", 1)
                os.environ[key] = value
            else:
                print(f"Ignoring line: {line}")

    # Access the environment variables in Python
    root = os.environ.get("root")
    ROOTFS = os.path.join(root, "home", "root")

    print("ROOTFS:", ROOTFS)
    print("TEST_SHEET:", TEST_SHEET)
    print("TEST_ID:", TEST_ID)
    print("PROJECT_SOURCE_DIR:", PROJECT_SOURCE_DIR)
    print("PROJECT_BINARY_DIR", PROJECT_BINARY_DIR)

    shutil.copy2(
        PROJECT_SOURCE_DIR + "/gen4/scripts/target_scripts/atf_it_ERRATA_cmd.sh", ROOTFS
    )

    os.environ["COMMAND"] = f"./atf_it_ERRATA_cmd.sh {TEST_ID}"
    os.environ["TEST_COMMAND"] = f"./atf_it_ERRATA_cmd.sh {TEST_ID}"

    test_case_execute(
        TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
    )
    #subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    #trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    #usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    #data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "Logging.cmm")
    #os.system(f"{trace32} -c {usb_port} -s {data_script}")

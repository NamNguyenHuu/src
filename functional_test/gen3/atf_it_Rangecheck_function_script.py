import os
import sys
import subprocess
import shutil
from helpers import test_with_normal_boot


test_defined_table = [
    ["TC1", "Rangecheck_function", "9", "2", "11111110"],
    ["TC2", "Rangecheck_function", "9", "2", "11111110"],
    ["TC3", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC4", "Rangecheck_function", "9", "2", "11111110"], 
    ["TC5", "Rangecheck_function", "9", "2", "11111110"],
    ["TC6", "Rangecheck_function", "9", "2", "11111110"],
    ["TC7", "Rangecheck_function", "9", "2", "11111110"],
    ["TC8", "Rangecheck_function", "9", "2", "11111110"],
    ["TC9", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC10", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC11", "Rangecheck_function", "9", "2", "11111110"],
    ["TC12", "Rangecheck_function", "9", "2", "11111110"],
    ["TC13", "Rangecheck_function", "9", "2", "11111110"],
    ["TC14", "Rangecheck_function", "10", "2", "11111110"], # BL2: Booting BL31
    ["TC15", "Rangecheck_function", "9", "2", "11111110"],
    ["TC16", "Rangecheck_function", "9", "2", "11111110"],
    ["TC17", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC18", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC19", "Rangecheck_function", "9", "2", "11111110"],
    ["TC20", "Rangecheck_function", "9", "2", "11111110"],
    ["TC21", "Rangecheck_function", "9", "2", "11111110"],
    ["TC22", "Rangecheck_function", "9", "2", "11111110"],
    ["TC23", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC24", "Rangecheck_function", "9", "2", "11111110"], # Local test
    ["TC25", "Rangecheck_function", "9", "2", "11111110"],
    ["TC26", "Rangecheck_function", "9", "2", "11111110"],
    ["TC27", "Rangecheck_function", "9", "2", "11111110"],
    ["TC28", "Rangecheck_function", "6", "2", "11111110"], # Normal Boot
    ["TC29", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC30", "Rangecheck_function", "9", "2", "11111110"],
    ["TC31", "Rangecheck_function", "10", "2", "11111110"], # BL2: Booting BL31
    ["TC32", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC33", "Rangecheck_function", "9", "2", "11111110"], # Local test
    ["TC34", "Rangecheck_function", "9", "2", "11111110"], # Local test
    ["TC35", "Rangecheck_function", "10", "2", "11111110"], # BL2: Booting BL31
    ["TC36", "Rangecheck_function", "9", "2", "11111110"],
    ["TC37", "Rangecheck_function", "10", "2", "11111110"], # BL2: Booting BL31
    ["TC38", "Rangecheck_function", "9", "2", "11111110"],
    ["TC39", "Rangecheck_function", "10", "2", "11111110"], # BL2: Booting BL31
    ["TC40", "Rangecheck_function", "9", "2", "11111110"], 
    ["TC41", "Rangecheck_function", "10", "2", "11111110"], # Bl2: Booting BL31
    ["TC42", "Rangecheck_function", "9", "2", "11111110"], # Not test
    ["TC43", "Rangecheck_function", "9", "2", "11111110"],
    ["TC44", "Rangecheck_function", "9", "2", "11111110"],
    ["TC45", "Rangecheck_function", "9", "2", "11111110"],
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
        PROJECT_SOURCE_DIR + "/gen3/scripts/target_scripts/atf_it_Rangecheck_function_cmd.sh", 
        ROOTFS,
    )

    os.environ["COMMAND"] = f"./atf_it_Rangecheck_function_cmd.sh {TEST_ID}"
    os.environ["TEST_COMMAND"] = f"./atf_it_Rangecheck_function_cmd.sh {TEST_ID}"
    test_case_execute(
        TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
    )
    #subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    #trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    #usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    #data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "Logging.cmm")
    #os.system(f"{trace32} -c {usb_port} -s {data_script}")

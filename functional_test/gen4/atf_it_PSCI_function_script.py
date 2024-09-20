import os
import sys
import subprocess
import shutil
from helpers import test_with_normal_boot


test_defined_table = [
    ["TC1", "PSCI_function", "1", "25", "111111100"],
    ["TC2", "PSCI_function", "1", "25", "111111100"],     # Test run many tcs
    ["TC3", "PSCI_function", "1", "25", "111111100"],
    ["TC4", "PSCI_function", "1", "25", "111111100"],             # SPECIFIED OPTION "-DDBGLOG - DDBG_CPU_SUSPEND_DOWN"
    ["TC5", "PSCI_function", "1", "25", "111111100"],
    ["TC6", "PSCI_function", "1", "25", "111111100"],
    ["TC7", "PSCI_function", "1", "25", "111111100"],

    ["TC8", "PSCI_function", "1", "28", "111111100"],
    ["TC9", "PSCI_function", "1", "28", "111111100"],
    ["TC10", "PSCI_function", "1", "28", "111111100"],            # SPECIFIED OPTION "-DDBGLOG - DDBG_CPU_SUSPEND_DOWN_HALF_CLUSTER"
    ["TC11", "PSCI_function", "1", "28", "111111100"],

    ["TC12", "PSCI_function", "1", "27", "111111100"],
    ["TC13", "PSCI_function", "1", "27", "111111100"],
    ["TC14", "PSCI_function", "1", "27", "111111100"],
    ["TC15", "PSCI_function", "1", "27", "111111100"],            # SPECIFICATION OPTION " -DDBGLOG - DDBG_CPU_SUSPEND_DOWN_CLUSTER"
    ["TC16", "PSCI_function", "1", "27", "111111100"],
    ["TC17", "PSCI_function", "1", "27", "111111100"],
    ["TC18", "PSCI_function", "1", "27", "111111100"],

    ["TC19", "PSCI_function", "1", "29", "111111100"],
    ["TC20", "PSCI_function", "1", "29", "111111100"],
    ["TC21", "PSCI_function", "1", "29", "111111100"],            # SPECIFICATION OPTION "-DDBGLOG -DDBG_CPU_SUSPEND_DOWN_SYSTEM"
    ["TC22", "PSCI_function", "1", "29", "111111100"],
    ["TC23", "PSCI_function", "1", "29", "111111100"],
    ["TC24", "PSCI_function", "1", "29", "111111100"],
    ["TC25", "PSCI_function", "1", "29", "111111100"],

    ["TC26", "PSCI_function", "1", "26", "111111100"],
    ["TC27", "PSCI_function", "1", "26", "111111100"],
    ["TC28", "PSCI_function", "1", "26", "111111100"],
    ["TC29", "PSCI_function", "1", "26", "111111100"],            # SPECIFIED OPTION "-DDBGLOG - DDBG_CPU_SUSPEND_STBY"
    ["TC30", "PSCI_function", "1", "26", "111111100"],
    ["TC31", "PSCI_function", "1", "26", "111111100"],
    ["TC32", "PSCI_function", "1", "26", "111111100"],

    ["TC33", "PSCI_function", "1", "210", "111111100"],
    ["TC34", "PSCI_function", "1", "210", "111111100"],
    ["TC35", "PSCI_function", "1", "210", "111111100"],
    ["TC36", "PSCI_function", "1", "210", "111111100"],            # SPECIFIED OPTION "-DDBGLOG - DDBG_CPU_SUSPEND_STBY_CLUSTER"
    ["TC37", "PSCI_function", "1", "210", "111111100"],
    ["TC38", "PSCI_function", "1", "210", "111111100"],
    ["TC39", "PSCI_function", "1", "210", "111111100"],

    ["TC40", "PSCI_function", "1", "211", "111111100"],
    ["TC41", "PSCI_function", "1", "211", "111111100"],
    ["TC42", "PSCI_function", "1", "211", "111111100"],
    ["TC43", "PSCI_function", "1", "211", "111111100"],            # SPECIFIED OPTION "-DDBGLOG - DDBG_CPU_SUSPEND_STBY_SYSTEM"
    ["TC44", "PSCI_function", "1", "211", "111111100"],
    ["TC45", "PSCI_function", "1", "211", "111111100"],
    ["TC46", "PSCI_function", "1", "211", "111111100"],

    ["TC47", "PSCI_function", "1", "10", "111111100"],# Test run different TP
    ["TC48", "PSCI_function", "1", "10", "111111100"],
    ["TC49", "PSCI_function", "1", "10", "111111100"],
    ["TC50", "PSCI_function", "1", "10", "111111100"],
    ["TC51", "PSCI_function", "1", "10", "111111100"],
    ["TC52", "PSCI_function", "1", "10", "111111100"],
    ["TC53", "PSCI_function", "1", "10", "111111100"],

    ["TC54", "PSCI_function", "1", "22", "111111100"],            # SPECIFIED OPTION "-DDBGLOG - DDBG_CPUX_ON_NG"
    ["TC55", "PSCI_function", "1", "22", "111111100"],


    ["TC56", "PSCI_function", "1", "0", "111111100"],    # Test run without TP
    ["TC57", "PSCI_function", "1", "0", "111111100"],
    ["TC58", "PSCI_function", "1", "0", "111111100"],
    ["TC59", "PSCI_function", "1", "0", "111111100"],
    ["TC60", "PSCI_function", "1", "0", "111111100"],
    ["TC61", "PSCI_function", "1", "0", "111111100"],
    ["TC62", "PSCI_function", "1", "0", "111111100"],

    ["TC63", "PSCI_function", "1", "23", "111111100"],            # SPECIFIED OPTION "-DDBGLOG -DDBG_CPU_OFF"

    ["TC64", "PSCI_function", "1", "10", "111111100"], # As the same time TC47

    ["TC65", "PSCI_function", "1", "0", "111111100"],

    ["TC66", "PSCI_function", "1", "0", "111111100"],

    ["TC67", "PSCI_function", "1", "216", "111111100"], #TP0_2 "-DDBGLOG -DDBG_CPU_OFF_CPUNG

    ["TC68", "PSCI_function", "1", "0", "111111100"],

    ["TC69", "PSCI_function", "1", "10", "111111100"], #TP0_10

    ["TC70", "PSCI_function", "1", "0", "111111100"],

    ["TC73", "PSCI_function", "1", "219", "111111100"], # "-DDBGLOG -DDBG_SYSTEM_SUSPEND_CPUNG"
    ["TC74", "PSCI_function", "1", "218", "111111100"],  # -DDBGLOG -DDBG_SYSTEM_SUSPEND

    ["TC75", "PSCI_function", "1", "213", "111111100"], # -DDBGLOG -DDBG_CPU2_OFF_CPU3_ON + TP6
    ["TC76", "PSCI_function", "1", "214", "111111100"], # -DDBGLOG -DDBG_CPU2_SUSPEND_CPU3_ON + TP6

    ["TC77", "PSCI_function", "1", "212", "111111100"], # -DDBGLOG -DDBG_OTHER_FEATURES


    ["TC78", "PSCI_function", "1", "7", "111111100"],     # Tets run with TP7

    ["TC79", "PSCI_function", "1", "7_8", "111111100"],  # Test run with TP7 and TP8
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
        PROJECT_SOURCE_DIR + "/gen4/scripts/target_scripts/atf_it_PSCI_cmd.sh", ROOTFS
    )

    os.environ["COMMAND"] = f"./atf_it_PSCI_cmd.sh {TEST_ID}"
    os.environ["TEST_COMMAND"] = f"./atf_it_PSCI_cmd.sh {TEST_ID}"

    test_case_execute(
        TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
    )
    subprocess.call('/opt/t32/bin/pc_linux64/t32usbchecker')
    trace32 = os.path.join("/opt/t32/bin/pc_linux64/t32marm64")
    usb_port = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32", "myconfig.t32")
    data_script = os.path.join(PROJECT_SOURCE_DIR, "gen4/scripts/trace32/T32_Script", "TS-004_print_apmu_registers.cmm")
    os.system(f"touch my_append.txt")
    with open("my_append.txt", 'a') as file:
        file.write(str(TEST_ID) + '\n')
    file.close()
    if (TEST_ID == "TC1" or TEST_ID == "TC8" or TEST_ID == "TC12" or TEST_ID == "TC19" or TEST_ID == "TC26" or TEST_ID == "TC54" or TEST_ID == "TC47" or TEST_ID == "TC56" or TEST_ID == "TC63") :
        os.system(f"{trace32} -c {usb_port} -s {data_script}")
        with open("my_append.txt", "r") as file:
            content = file.read()
            print(content)
        file.close()
    else :
        print("Test case not using TRACE32")
    #os.system(f"rm my_append.txt")
    #print("REMOVE my_append.txt SUCCESSFULLY <3")

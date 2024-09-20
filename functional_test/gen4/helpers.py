from os.path import join
from os import system
from subprocess import call
from scripts.atf_it_exe_functions import get_testcfg_from_tbl


def test_with_normal_boot(
    TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR, ROOTFS
) -> None:
    testcfg = get_testcfg_from_tbl(
        TEST_SHEET, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR
    )
    TEST_SHEET = testcfg[0]
    TEST_ID = testcfg[1]
    CFG = testcfg[2]
    TP = testcfg[3]
    Burn_mode = testcfg[4]
    print("TEST_SHEET:", TEST_SHEET)
    print("TEST_ID:", TEST_ID)
    print("CFG:", CFG)
    print("TP:", TP)
    print("Burn_mode:", Burn_mode)
    common_cmd = join(PROJECT_SOURCE_DIR, "scripts", "common_cmd.sh")
    # exec_test = join(PROJECT_SOURCE_DIR, "gen4/scripts", "exec_test.sh")

    try:
        call(["bash", common_cmd, CFG, TP, Burn_mode, TEST_SHEET, TEST_ID])
        # call(["bash", exec_test, CFG, TP, Burn_mode, TEST_SHEET, TEST_ID])
    except Exception as e:
        print(f"Error executing the script: {e}")

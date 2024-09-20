import shutil
import os
import sys


def naming_output_bl31(CFG, TP, BUILD_4BOARD, binary_local_path):
    bl31_config_srec = f"bl31_BUILD_CFG_{CFG}_TP_NUM_{TP}-{BUILD_4BOARD}.srec"
    bl2_config_srec = f"bl2_BUILD_CFG_{CFG}_TP_NUM_{TP}-{BUILD_4BOARD}.srec"
    bootparam_sa0_config_srec = f"bootparam_sa0_BUILD_CFG_{CFG}_TP_NUM_{TP}-{BUILD_4BOARD}.srec"
    cert_header_sa6_config_srec = f"cert_header_sa6_BUILD_CFG_{CFG}_TP_NUM_{TP}-{BUILD_4BOARD}.srec"
    if TP == "2":
        print("rename image for TP", TP)
        os.chdir(PROJECT_BINARY_DIR + "/out/prepare/prefix_build_atf/Result_tp_2")
        naming(CFG, BUILD_4BOARD, bl31_config_srec, bl2_config_srec, bootparam_sa0_config_srec, cert_header_sa6_config_srec, binary_local_path)
        print("copy done from Result_tp_2")
    elif TP == "1":
        print("rename image for TP", TP)
        os.chdir(PROJECT_BINARY_DIR + "/out/prepare/prefix_build_atf/Result_tp_1")
        naming(CFG, BUILD_4BOARD, bl31_config_srec, bl2_config_srec, bootparam_sa0_config_srec, cert_header_sa6_config_srec, binary_local_path)
        print("copy done from Result_tp_1")

def naming(CFG, BUILD_4BOARD, bl31_config_srec, bl2_config_srec, bootparam_sa0_config_srec, cert_header_sa6_config_srec, binary_local_path):
    try:
        os.rename(f"bl31_{CFG}-{BUILD_4BOARD}.srec", f"{bl31_config_srec}")
        shutil.copy2(bl31_config_srec, binary_local_path)
        os.rename(f"bl2_{CFG}-{BUILD_4BOARD}.srec", f"{bl2_config_srec}")
        shutil.copy2(bl2_config_srec, binary_local_path)
        os.rename(f"bootparam_sa0_{CFG}-{BUILD_4BOARD}.srec", f"{bootparam_sa0_config_srec}")
        shutil.copy2(bootparam_sa0_config_srec, binary_local_path)
        os.rename(f"cert_header_sa6_{CFG}-{BUILD_4BOARD}.srec", f"{cert_header_sa6_config_srec}")
        shutil.copy2(cert_header_sa6_config_srec, binary_local_path)

    except Exception:
        raise ("Error: " + Exception)
    os.chdir(binary_local_path)
    if BUILD_4BOARD == "salvator-x":
        os.rename(bl31_config_srec, "bl31-salvator-x.srec")
        os.rename(bl2_config_srec, "bl2-salvator-x.srec")
        os.rename(bootparam_sa0_config_srec, "bootparam_sa0.srec")
        os.rename(cert_header_sa6_config_srec, "cert_header_sa6.srec")
    elif BUILD_4BOARD == "ebisu":
        os.rename(bl31_config_srec, "bl31-salvator-x.srec")
        os.rename(bl2_config_srec, "bl2-salvator-x.srec")
        os.rename(bootparam_sa0_config_srec, "bootparam_sa0.srec")
        os.rename(cert_header_sa6_config_srec, "cert_header_sa6.srec")


if __name__ == "__main__":
    CFG = sys.argv[1]
    TP = sys.argv[2]
    BUILD_4BOARD = sys.argv[3]
    binary_local_path = sys.argv[4]
    PROJECT_BINARY_DIR = sys.argv[5]
    naming_output_bl31(CFG, TP, BUILD_4BOARD, binary_local_path)

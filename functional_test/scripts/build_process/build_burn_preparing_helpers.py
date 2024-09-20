#!/usr/bin/python3

import sys
import subprocess
import os
import glob
import logging

# import difflib
from difflib import Differ
from importlib import import_module

differ = Differ()


def sort_table_build_cfg_tp(data_extract_for_build):
    sorted_data = sorted(data_extract_for_build, key=lambda x: int(x[2]))
    return sorted_data


def gather_test_defined_tables(script_dir):
    total_test_defined_table = []

    # Change to script dir (before including files)
    current_dir = os.getcwd()
    os.chdir(script_dir)

    sys.path.append(script_dir)
    pattern = "atf_it_*_script.py"
    files = glob.glob(pattern)
    for file in files:
        filename, ext = file.split(".", 1)
        moduleName = import_module(filename)
        sorted_data = moduleName.test_defined_table
        if TEST_SORTING_LEVEL == TEST_SORTING_FOR_FEATURE:
            sorted_data = sort_table_build_cfg_tp(moduleName.test_defined_table)

        for element in sorted_data:
            total_test_defined_table.append(element)
        if TEST_SORTING_LEVEL == TEST_SORTING_FOR_TOTAL:
            sorted_data = sort_table_build_cfg_tp(total_test_defined_table)

    # Change to current dir (after including files)
    os.chdir(current_dir)
    return total_test_defined_table


######################################################
# FUNC  : send data(cfg and tp) and build optee-os   #
# Input : data_pre_build(TC,Sheet,CFGS,TP)           #
# Output:  tee.srec                                  #
######################################################

def send_data_and_build(data_send):  ### func: send_data_and_build
    for i in range(len(data_send)):
        print("Sending CFGS", data_send[i][2])  ##logging_func
        print("Sending TP", data_send[i][3])  ##logging_func
        RE_TP = 0
        if i > 0:
            RE_TP = data_send[i - 1][3]

        ssh_command = f"bash {project_src_dir}/scripts/pre-built_atf_it.sh {data_send[i][2]} {data_send[i][3]} {RE_TP} {env_file}"
        ret = os.system(ssh_command)


################################################################################
#  FUNC  : convert Cmakelist to Python list                                    #
#  Input : Cmakelist (e.g. sample of input:                                    #
#      TC1;Exception_function;TC2;Exception_function;TC3;Exception_function...)#
#  Output: Python_list                                                         #
################################################################################


def convert_cmakelist_2_pylist(cmakelist):
    # handling the test request send from cmake cut ; from test_feature_list
    test_define = cmakelist.split(";")
    # Convert to list in python
    test_define = list(test_define)
    # handling list number 2 can fixed because we only send 2 agrs :TEST_ID,TEST_SHEET
    test_define = [test_define[i : i + 2] for i in range(0, len(test_define), 2)]
    return test_define


################################################################################
#  FUNC  : remove_duplicate_tc                                                 #
#  Input : Python_list w many TCs duplicate  (e.g. sample of input:            #
#     ([['TC1', 'Exception_function'], ['TC2', 'Exception_function'], ...]])   #
#  Output: Python_list w unique TCs                                            #
################################################################################


def remove_duplicate_tc(test_define_request):
    ##input data : test_feature_list
    print("input", test_define_request)
    filted_test_define_request = []
    ##handling duplicate define testcase in test_feature_list in cmake
    for item in test_define_request:
        match_found = False
        for value in filted_test_define_request:
            if item[1] == value[1]:
                if item[0] == value[0]:
                    match_found = True
                    break
        if not match_found:
            filted_test_define_request.append(item)
    ##showing data after filted
    print("data_filted", filted_test_define_request)
    modified_test_define = filted_test_define_request
    # sort_table_build_cfg_tp(modified_test_define)
    return modified_test_define


####################################################
# FUNC  : remove_duplicate_build_cfg_tp            #
# Input : Python_list w many TCs duplicate(CFGS_TP)#
# Output: Python_list w unique (CFGS_TP)           #
####################################################


def remove_duplicate_build_cfg_tp(data_havecfg):
    filted_build_cfg_list = []
    print("data", data_havecfg)
    item_count = 0
    # item_count=0
    for item in range(len(data_havecfg)):
        match_found = False

        if len(filted_build_cfg_list) == 0:
            filted_build_cfg_list.append(data_havecfg[item])
        else:
            for value in range(len(filted_build_cfg_list)):
                if data_havecfg[item][2] == filted_build_cfg_list[value][2]:
                    if data_havecfg[item][3] == filted_build_cfg_list[value][3]:
                        item_count += 1
                        match_found = True
            if not match_found:
                filted_build_cfg_list.append(data_havecfg[item])
                # build_config_list.append(data_append)
                print("Added new data: ", filted_build_cfg_list)
    data_for_pre_build = filted_build_cfg_list
    return data_for_pre_build


####################################################
# FUNC  : collect_data_cfgs_from_total_list        #
# Input : TCs and Sheet no CFGS_TP                 #
# Output: TCs and Sheet have CFGS_TP               #
####################################################

def collect_data_cfgs_from_total_list(modified_test_define, build_total_list):
    diff = []
    ##compare test_feature_list and total_feature_list to get cfg and tp
    for value in range(len(build_total_list)):
        match_found = False
        for item in range(len(modified_test_define)):
            if modified_test_define[item][0] == build_total_list[value][0]:
                if modified_test_define[item][1] == build_total_list[value][1]:
                    add_data_to_build = build_total_list[value]
                    match_found = True
                    diff.append(add_data_to_build)
    extracted_test_tbl = diff
    return extracted_test_tbl


##################################################################
#    MAIN FUNC: prepare_build_data                               #
#    Input : convert_list,remove_duplicate_TCs,CFGS_TP           #
#    Ouput : TOTAL_FEATURE_LIST                                  #
##################################################################

def prepare_build_data(total_test_tbl, cmake_test_list, prj_bin_dir):
    print("cmake_test_list:", cmake_test_list)
    file_sub = prj_bin_dir + "/EXTRACT_TEST_FEATURE_LIST.txt"

    # Call function to convert cmakelist and diff
    test_define = convert_cmakelist_2_pylist(cmake_test_list)
    print(f"test_define: {test_define}")
    # Checking duplicate TCs
    modified_test_define = remove_duplicate_tc(test_define)
    # Get CFGS_TP from total_feature_list to build
    extracted_test_tbl = collect_data_cfgs_from_total_list(
        modified_test_define, total_test_tbl
    )
    # Checking duplicate CFGS_TP
    data_for_pre_build = remove_duplicate_build_cfg_tp(extracted_test_tbl)
    print(f"data_for_pre_build: {data_for_pre_build}")
    # Sending TP and CFGS to prebuild optee-os
    processing = send_data_and_build(data_for_pre_build)
    # print (file_sub)
    with open(file_sub, "w") as filesort:
        for item in extracted_test_tbl:
            # creates a list named column_widths that specifies the width of each column
            column_widths = [5, 20, 5, 5, 5, 5, 5]
            # uses  list comprehension to iterate over each element in the item and corresponding width in column_widths
            formatted_item = [
                str(element).ljust(width) for element, width in zip(item, column_widths)
            ]
            # filesort.write(' '.join(map(str, item)) + "\n")
            filesort.write(" ".join(formatted_item) + "\n")


if __name__ == "__main__":

    project_src_dir = sys.argv[2]
    env_file = sys.argv[4]
    TEST_SORTING_LEVEL = sys.argv[5]
    TEST_SORTING_NONE = 0
    TEST_SORTING_FOR_FEATURE = 1
    TEST_SORTING_FOR_TOTAL = 2
    current_platform = os.environ.get("CURRENT_PLATFORM")
    platform_dir = f"{project_src_dir}/{current_platform}"

    # scan through the python file and collect test configs in test_defined_tbl                                   
    total_test_defined_tbl = gather_test_defined_tables(platform_dir)

    if len(sys.argv) > 1:
        # add test configs to the /EXTRACT_TEST_FEATURE_LIST.txt file and execute pre-built_atf_if.sh to build ATF
        prepare_build_data(total_test_defined_tbl, sys.argv[1], sys.argv[3])
    else:
        print("Usage: python3 script.py <value>")
        sys.exit(1)

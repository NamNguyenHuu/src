import sys
from scripts.atf_it_fucntions import get_elements_tc_sheet


#   Funtion name: get_testcfg_from_tbl()
#   Description: Call get_elements_tc_sheet() function to get every element of information of each test cases which is defined in test spec,
#   Input:
#           Sheet_Test_Name: the name of sheet which is tested
#           TEST_ID: Id of test case which is tested
#           PROJECT_SRC_DIR: The path
#           PROJECT_BINARY_DIR: the path
#   Output: Return a array_return which contains information of test cases which is tested

def get_testcfg_from_tbl(TestFeature,TEST_ID,PROJECT_SOURCE_DIR,PROJECT_BINARY_DIR):
    array_return=[]
    array_return = get_elements_tc_sheet(TestFeature, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR)
    return array_return


if __name__ == '__main__':
    TestFeature = sys.argv[1]
    TEST_ID = sys.argv[2]
    PROJECT_SOURCE_DIR = sys.argv[3]
    PROJECT_BINARY_DIR = sys.argv[4]
    get_testcfg_from_tbl(TestFeature, TEST_ID, PROJECT_SOURCE_DIR, PROJECT_BINARY_DIR)

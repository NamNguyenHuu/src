import sys
import array
import subprocess


#   Funtion name: get_elements_tc_sheet()
#   Description: Get every element of information of each test cases which is defined in test spec,
#   Input:
#           Sheet_Test_Name: the name of sheet which is tested
#           TEST_ID: Id of test case which is tested
#           PROJECT_SRC_DIR: The path
#           PROJECT_BINARY_DIR: the path
#   Output: Return a array which contains information of test cases which is tested

def get_elements_tc_sheet(Sheet_Test_Name, TEST_ID, PROJECT_SRC_DIR, PROJECT_BINARY_DIR):
    content = open(PROJECT_BINARY_DIR +'/EXTRACT_TEST_FEATURE_LIST.txt','r').readlines()

    content_array=[]
    for line in content:
        line = line.strip("\n").strip()
        var = line.split()
        content_array.append(var)

    for line in content_array:
        if TEST_ID == line[0].strip("''"):
            if Sheet_Test_Name == line[1].strip("''"):
                TEST_ID = line[0].strip("''")
                Sheet_Test_Name = line[1].strip("''")
                CFG = line[2].strip("'")
                TP = line[3].strip("'")
                Burn_mode = line[4].strip("''")
                array=[]
                array.append(Sheet_Test_Name)
                array.append(TEST_ID)
                array.append(CFG)
                array.append(TP)
                array.append(Burn_mode)
                print("array test:",array)
                return array
            else:
                print("This test case isn't test")
        else:
            print("Skip this test case")


if __name__ == '__main__':
    Sheet_Test_Name = sys.argv[1]
    TEST_ID = sys.argv[2]
    PROJECT_SRC_DIR=sys.argv[3]
    PROJECT_BINARY_DIR=sys.argv[4]
    get_elements_tc_sheet(Sheet_Test_Name, TEST_ID, PROJECT_SRC_DIR, PROJECT_BINARY_DIR)

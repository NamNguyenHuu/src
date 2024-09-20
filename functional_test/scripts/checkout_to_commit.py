import sys
import tp_src_mapping
import subprocess
import os
import shutil

# define function to use for building feature
# define function checkout to correctly src code base TP config of TP_MAPPING_TABLE
# Function name: checkout_to_commit --> checkout to correctly src code of optee base TP config, 
#                 Get TP as a input and call function get_elements_tp_mapping_tp() to get other coressponse elements to TP      
# Input: 
#         TP: Test program of each test case 
#         SCRIPT: This is a path to scritp of optee
# Output: NULL

def checkout_to_commit(TP, SCRIPTS,PROJECT_BINARY_DIR):
    result = tp_src_mapping.get_elements_tp_mapping_tp(TP, SCRIPTS)

    atf_git_commit_id = result[1]

    # checkout source optee_os
    path_atf= os.chdir(PROJECT_BINARY_DIR +'/arm-trusted-firmware')
    print(f"Changed directory to: {path_atf}")
    try:
        # Run the git checkout command
        subprocess.run(['git', 'checkout', atf_git_commit_id], check=True)
        print(f"Checked out to commit {atf_git_commit_id}")
    except subprocess.CalledProcessError as e:
        print(f"Error checking out to commit {atf_git_commit_id}: {e}")

    #checkout source optee_test
   
if __name__ == '__main__':
    TP = sys.argv[1]
    SCRIPTS = sys.argv[2]
    PROJECT_BINARY_DIR = sys.argv[3]
    checkout_to_commit(TP, SCRIPTS, PROJECT_BINARY_DIR)

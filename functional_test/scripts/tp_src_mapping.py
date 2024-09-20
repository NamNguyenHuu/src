import sys

#   function name: get_elements_tp_mapping_tp : get correctly elements of TO_MAPPING_TABLE based on TP, that table is defined in gen3 cmake
#       input: TP, SCRIPT
#       output: return a array contain configs but: TP, atf_git_commit_id, smc_dummy_commit_id

def get_elements_tp_mapping_tp(TP,SCRIPTS):
    table = open(SCRIPTS +'/TP_Mapping_Table.txt','r').readlines()
    table_array=[]
    for line in table:
        line = line.strip("\n").strip()
        var = line.split()
        table_array.append(var)
    for line in table_array:
        if TP == line[0]:
            TP = line[0]
            atf_git_commit_id = line[1]
            result_array = []
            result_array.append(TP)
            result_array.append(atf_git_commit_id)
            return result_array

if __name__ == '__main__':
    TP = sys.argv[1]
    SCRIPTS = sys.argv[2]
    get_elements_tp_mapping_tp(TP, SCRIPTS)

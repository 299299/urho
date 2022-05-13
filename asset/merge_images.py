#!/usr/bin/python3

import sys
import os
import glob

if __name__ == "__main__":
    print (sys.argv)

    search_pat = sys.argv[1]
    output_folder_name = sys.argv[2] + '/'
    input_prefix_name = sys.argv[3]

    os.system ("mkdir -p " + output_folder_name)

    files = glob.glob(search_pat)
    print (files)

    index = 0

    for file in files:
        ext = os.path.splitext(file)[1]
        target_file = output_folder_name + input_prefix_name + "_" + str(index) + ext
        os.system('cp ' + file + ' ' + target_file)
        index += 1

        idx = file.rfind('/')
        file = file[0:idx+1]

        #os.system ('rm -rf ' + file)
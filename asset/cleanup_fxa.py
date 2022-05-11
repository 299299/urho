#!/usr/bin/python3

import sys
import os
import glob

if __name__ == "__main__":
    print (sys.argv)
    search_pat = sys.argv[1]
    output_folder_name = sys.argv[2]

    os.system ("mkdir -p " + output_folder_name)

    files = glob.glob(search_pat)
    #print (files)

    for file in files:
        file_list = os.listdir(file)
        non_fxa_found = False
        for f in file_list:
            if not f.endswith('.fxa'):
                non_fxa_found = True
                break;
        if not non_fxa_found:
            #print (file)
            file = file.rstrip('/')
            idx = file.rfind('/')
            #print (file)
            file = file[0:idx+1]
            #print (file)

            os.system ('mv -f ' + file + ' ' + output_folder_name)

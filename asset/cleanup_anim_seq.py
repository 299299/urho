#!/usr/bin/python3

import sys
import os
import glob

if __name__ == "__main__":
    print (sys.argv)
    search_pat = sys.argv[1]
    output_folder_name = sys.argv[2]

    files = glob.glob(search_pat, recursive=True)

    for file in files:
        print (file)
        os.system ('mv -f ' + file + ' ' + output_folder_name)

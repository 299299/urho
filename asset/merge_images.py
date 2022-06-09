#!/usr/bin/python3

import sys
import os
import glob

if __name__ == "__main__":
    print (sys.argv)

    search_pat = sys.argv[1]
    output_folder_name = sys.argv[2] + '/'

    os.system ("mkdir -p " + output_folder_name)

    files = glob.glob(search_pat, recursive=True)
    print (files)

    file_dict = {}

    for file in files:

        file_name_without_ext = os.path.splitext(file)[0]
        output_img_name = os.path.basename(file_name_without_ext)

        target_file = output_folder_name + output_img_name + '.tga'
        if os.path.exists(target_file):
            if output_img_name in file_dict:
                file_dict[output_img_name] = file_dict[output_img_name] + 1
            else:
                file_dict[output_img_name] = 1

            target_file = output_folder_name + output_img_name + '_' + str(file_dict[output_img_name]) + '.tga'


        os.system('cp ' + file + ' ' + target_file)

        idx = file.rfind('/')
        file = file[0:idx+1]

        #os.system ('rm -rf ' + file)
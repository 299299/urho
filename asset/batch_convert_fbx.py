#!/usr/bin/python3

import sys
import os
import glob
import subprocess

model_convert_script='./convert_model.py'

if __name__ == "__main__":

    print(r"""\

                               ._ o o
                               \_`-)|_
                            ,""       \
                          ,"  ## |   ಠ ಠ.
                        ," ##   ,-\__    `.
                      ,"       /     `--._;)
                    ,"     ## /
                  ,"   ##    /


            """)
    print ("batch_convert_model.py [input fbx path] [options]")

    input_path = sys.argv[1] + '/'

    search_pat = input_path + '**/*.fbx'
    fbx_files = glob.glob(search_pat, recursive=True)

    #print (fbx_files)
    for fbx in fbx_files:
        cmd = 'python3 ' + model_convert_script + ' ' + fbx + ' Export_Objects/'
        # print (cmd)
        os.system(cmd)





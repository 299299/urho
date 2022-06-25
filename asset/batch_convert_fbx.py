#!/usr/bin/python3

import sys
import os
import glob
import subprocess
import time

model_convert_script='./convert_fbx.py'
mat_error_file = '/tmp/asset_mat_error'

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
    print ("batch_convert_fbx.py [input fbx path] [options]")

    input_path = sys.argv[1] + '/'

    search_pat = input_path + '**/*.fbx'
    fbx_files = glob.glob(search_pat, recursive=True)

    args = ' -a /Users/golden/Downloads/game_resource/Life_Is_Strange_1/ '

    t1 = time.time()

    num_of_fbx = len(fbx_files)
    mat_error_fbx_files = []

    #print (fbx_files)
    for fbx in fbx_files:
        cmd = 'python3 ' + model_convert_script + ' ' + fbx + ' Export_Objects/' + args
        # print (cmd)
        os.system(cmd)
        if os.path.exists(mat_error_file):
            mat_error_fbx_files.append(fbx)

    t2 = time.time()
    print ("fbx converted = " + str(num_of_fbx) + " time cost=" + str(int(t2 - t1)) + " secs")

    print ("material error fbx num-files:" + str(len(mat_error_fbx_files)))
    print (mat_error_fbx_files)



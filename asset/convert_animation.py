#!/usr/bin/python3

import sys
import os
import glob
import subprocess

anim_args = "-nm -nt -mb 64 -np -l -s Gundummy02 Gundummy Bip01_Point_Gauntlet_Screen"
assimp_tool = "/build_osx/bin/tool/AssetImporter"
git_root_cmd = "git rev-parse --show-toplevel"
asset_output_folder = 'GameData/'
# asset_output_path = 'Export_Objects/'

def prepare_dir(dir):
    os.system("mkdir -p " + dir)

def convert_animation(tool, input_file, output_file, b_overwrite):
    if os.path.exists(output_file) and not b_overwrite:
        print (output_file + ' exist !')
        return

    run_cmd = tool + " model " + input_file + " " + output_file + " " + anim_args
    print (run_cmd)
    os.system(run_cmd)

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
    print ("convert_animation.py [input animation file] [output path] [options]")
    print ("-f to force overwrite animation")

    argv = sys.argv
    argv = argv[1:]

    b_overwrite = False
    for arg in argv:
        if arg == '-f':
            b_overwrite = True

    print ("args=" + str(argv))
    git_root = subprocess.getoutput(git_root_cmd)
    print ("git_root=" + git_root)

    input_path = argv[0]
    asset_output_path = argv[1]
    output_folder = git_root + '/bin/' + asset_output_folder + asset_output_path + '/'
    tool = git_root + assimp_tool

    prepare_dir(output_folder)

    if os.path.isdir(input_path):
        path_list = os.listdir(input_path)
        #print (path_list)
        for ipath in path_list:
            #print (ipath)
            i_fpath = input_path + '/' + ipath + '/'
            folder_created = False

            if os.path.isdir(i_fpath):
                anim_list = os.listdir(i_fpath)
                for anim_name in anim_list:
                    if anim_name.startswith('.'):
                        continue

                    anim_fname = i_fpath + anim_name
                    if os.path.isdir(anim_fname):
                        continue
                    #print (anim_fname)

                    file_name_without_ext = os.path.splitext(anim_name)[0]
                    output_anim_name = os.path.basename(file_name_without_ext)

                    anim_folder = output_folder + ipath
                    if not folder_created:
                        prepare_dir(anim_folder)
                        folder_created = True

                    output_ani = anim_folder + '/' + output_anim_name +  ".ani"
                    #print (output_ani)

                    convert_animation(tool, anim_fname, output_ani, b_overwrite)

    else:
        file_name_without_ext = os.path.splitext(input_path)[0]
        output_anim_name = os.path.basename(file_name_without_ext)

        print ('output_folder=' + output_folder)
        prepare_dir (output_folder)

        output_ani = output_folder + output_anim_name +  ".ani"
        convert_animation(tool, input_path, output_ani, b_overwrite)


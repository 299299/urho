#!/usr/bin/python3

import sys
import os
import glob

if __name__ == "__main__":
    print (sys.argv)

    input_folder = sys.argv[1]

    folder_list = os.listdir(input_folder)
    #print (folder_list)

    for folder in folder_list:
        full_path = input_folder + folder
        if os.path.isfile(full_path):
            continue

        tex_list = glob.glob(full_path + '/**/*.tga', recursive=True)
        mesh_list = glob.glob(full_path + '/**/*.psk', recursive=True)
        anim_list = glob.glob(full_path + '/**/*.psa', recursive=True)
        mesh_list2 = glob.glob(full_path + '/**/*.pskx', recursive=True)

        num_tex = len(tex_list)
        num_mesh = len(mesh_list)
        num_anim = len(anim_list)
        num_mesh2 = len(mesh_list2)

        if (num_tex == 0 and num_mesh == 0 and num_anim == 0 and num_mesh2 == 0):
            #@print (full_path)
            os.system('rm -rf ' + full_path)

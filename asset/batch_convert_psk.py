import bpy
import sys
import os
import glob
import time

#BLENDER='/Applications/Blender.app/Contents/MacOS/Blender'

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)

def load_pskx(input_file):
    bpy.ops.import_scene.psk(filepath=input_file)

def export_fbx(file_path):
    bpy.ops.export_scene.fbx(filepath=file_path, global_scale=0.0254, axis_forward='Z', axis_up='Y')

def convert_psk(input_file, output_folder):
    print ('convert_psk input_file=' + input_file + ' output_folder=' + output_folder)

    clear_scene()
    load_pskx(input_file)

    file_name_without_ext = os.path.splitext(input_file)[0]
    output_model_name = os.path.basename(file_name_without_ext)
    output_path = output_folder + '/' + output_model_name + '.fbx'

    export_fbx(output_path)

    #print ('convert_psk -----------------')

argv = sys.argv
argv = argv[argv.index("--") + 1:]  # get all args after "---"
print (argv)

t1 = time.time()

if len(argv) >= 2:
    input_folder=argv[0]
    output_folder=argv[1]

    search_pat=input_folder + '/**/*.pskx'
    pskx_files = glob.glob(search_pat, recursive=True)

    print (pskx_files)

    for pskx_file in pskx_files:
        convert_psk(pskx_file, output_folder)

    t2 = time.time()

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

    num_models = len(pskx_files)
    print ("model converted = " + str(num_models) + " time cost=" + str(int(t2 - t1)) + " secs")





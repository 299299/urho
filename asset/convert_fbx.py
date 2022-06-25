#!/usr/bin/python3

import sys
import os
import glob
import subprocess

model_args = "-mb 64 -t -np -na -l"
assimp_tool = "/build_osx/bin/tool/AssetImporter"
git_root_cmd = "git rev-parse --show-toplevel"
output_path = './export/'
mat_template_file = './mat_template.xml'
obj_template_file = './obj_template.xml'
character_template_file = './character_template.xml'
asset_output_folder = 'GameData/'
# asset_output_path = 'Export_Objects/'
mat_error_file = '/tmp/asset_mat_error'

def prepare_dir(dir):
    os.system("mkdir -p " + dir)

def report_error():
    os.system('touch ' + mat_error_file)

def guess_mat_file(asset_path, mat_name, output_model_name):
    search_pat = asset_path + '**/' + mat_name + '*.mat'
    mat_files = glob.glob(search_pat, recursive=True)

    # attempt #1
    if len(mat_files) == 0:
        #print (mat_name + ' not found !!')
        # in life strange material will be MT_xxx
        mat_name = output_model_name.replace("ST_", "MT_")
        print ("try search with " + mat_name)
        search_pat = asset_path + '**/' + mat_name + '*.mat'
        mat_files = glob.glob(search_pat, recursive=True)

    # attempt #2
    if len(mat_files) == 0:
        if str(mat_name[-1]).isupper():
            mat_name = mat_name[:-1]
        if str(mat_name[-1]) == '_':
            mat_name = mat_name[:-1]
        print ("try search with " + mat_name)
        search_pat = asset_path + '**/' + mat_name + '*.mat'
        mat_files = glob.glob(search_pat, recursive=True)

    # attempt #3
    if len(mat_files) == 0:
        if str(mat_name[-1]).isdigit():
            mat_name = mat_name[:-1]
        if str(mat_name[-1]).isdigit():
            mat_name = mat_name[:-1]

        print ("try search with " + mat_name)
        search_pat = asset_path + '**/' + mat_name + '*.mat'
        mat_files = glob.glob(search_pat, recursive=True)


    if len(mat_files) == 0:
        print (mat_name + ' not found !!')
        report_error()
        return ""

    return mat_files[0]

def process_material(mat_name, output_folder,
                     output_model_name, mat_template, asset_output_path,
                     b_character, b_overwrite, asset_path):
    print ("processing material " + mat_name)

    mat_file = guess_mat_file(asset_path, mat_name, output_model_name)

    if (mat_file == ""):
        return;

    diff = None
    specular = None
    normal = None
    emissive = None

    tech = "Diff"

    mat_path = os.path.dirname(mat_file)

    with open(mat_file, "r") as text_file:
        tex_list = text_file.read().splitlines()

    #print (tex_list)
    tex_pairs = []
    for tex_line in tex_list:
        tex_pairs.append (tex_line.split('='))

    for tex_words in tex_pairs:
        if tex_words[0] == 'Diffuse':
            diff = tex_words[1]
        if tex_words[0] == 'Normal':
            normal = tex_words[1]
        if tex_words[0] == 'Cube':
            specular = tex_words[1]
        if tex_words[0] == 'Specular':
            specular = tex_words[1]
        if tex_words[0] == 'Emissive':
            emissive = tex_words[1]

        if tex_words[1].endswith('_D') and not diff:
            diff = tex_words[1]
        if tex_words[1].endswith('_N') and not normal:
            normal = tex_words[1]

    # if diff is None:
    #     for tex_words in tex_pairs:
    #         if tex_words[1].endswith('_D'):
    #             diff = tex_words[1]
    #     for tex_words in tex_pairs:
    #         if tex_words[1].endswith('_N'):
    #             normal = tex_words[1]

    #print (mat_path)
    diff = find_texture(mat_path, diff)
    normal = find_texture(mat_path, normal)
    specular = find_texture(mat_path, specular)
    emissive = find_texture(mat_path, emissive)

    output_texture_folder = output_folder + "Textures/"
    texture_base_path = asset_output_path + output_model_name + "/Textures/"

    diff_tex_found = False

    if diff:
        os.system('cp -f ' + diff + ' ' + output_texture_folder)
        diff_tex_found =  os.path.exists(diff)
        diff = texture_base_path +  os.path.basename(diff)
    else:
        diff = "BaseWhite"
        diff_tex_found = False

    if not diff_tex_found:
        report_error()

    if normal:
        os.system('cp -f ' + normal + ' ' + output_texture_folder)
        normal = texture_base_path + os.path.basename(normal)

    if specular:
        os.system('cp -f ' + specular + ' ' + output_texture_folder)
        specular = texture_base_path + os.path.basename(specular)

    if emissive:
        os.system('cp -f ' + emissive + ' ' + output_texture_folder)
        emissive = texture_base_path + os.path.basename(emissive)

    if diff and normal and specular and emissive:
        tech = 'DiffNormalSpecEmissive'
    else:
        if diff and normal and specular:
            tech = 'DiffNormalSpec'
        else:
            if diff and normal:
                tech = 'DiffNormal'
            if diff and specular:
                tech = 'DiffSpec'
            if diff and emissive:
                tech = 'DiffEmissive'

    mat_text = mat_template.replace('@tech', tech)
    if diff:
        mat_text = mat_text.replace('@diffuse', diff)
    if normal:
        mat_text = mat_text.replace('@normal', normal)
    if specular:
        mat_text = mat_text.replace('@specular', specular)
    if emissive:
        mat_text = mat_text.replace('@emissive', emissive)
        mat_text = mat_text.replace('@color_emissive', '1.0 1.0 1.0 1.0')
    else:
        mat_text = mat_text.replace('@color_emissive', '0.0 0.0 0.0 1.0')

    #print (mat_text)
    mat_lines = mat_text.splitlines()

    output_mat_file = output_folder + 'Materials/' + mat_name + '.xml';
    #print (output_mat_file)

    if os.path.exists(output_mat_file) and not b_overwrite:
        print (output_mat_file + ' already exist!')
        return mat_name

    with open(output_mat_file, 'w') as output_mat:
        for mat_line in mat_lines:
            if '@' in mat_line:
                continue
            output_mat.write(mat_line + '\n')

    return mat_name

def find_texture(mat_path, text_name):
    if not text_name:
        return None

    search_pat = mat_path + '/../../' + '**/' + text_name + '.tga'
    #print (search_pat)
    diff_list = glob.glob(search_pat, recursive=True)
    if len(diff_list) > 0:
        ret = diff_list[0]
    else:
        ret = None
    return ret

def process_object(obj_name, output_folder, output_model_name, obj_template, mat_list, b_overwrite, asset_output_path):
    output_object_file = output_folder + output_model_name + '.xml'

    if os.path.exists(output_object_file) and not b_overwrite:
        print (output_object_file + ' already exist!')
        return

    asset_model_name = asset_output_path + output_model_name + '/' + output_model_name + '.mdl'
    # print (asset_model_name)

    obj_xml = obj_template.replace('@name', output_model_name)
    obj_xml = obj_xml.replace('@model', asset_model_name)

    asset_mat = ''
    for mat in mat_list:
        #print (mat)
        asset_mat += asset_output_path + output_model_name + '/' + mat + ';'
        #print (asset_mat)

    #print (asset_mat)
    asset_mat = asset_mat.rstrip(';')
    obj_xml = obj_xml.replace('@material', asset_mat)
    #print (obj_xml)

    with open(output_object_file, 'w') as f:
        f.write(obj_xml)


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
    print ("convert_model.py [input model file] [output path] [options]")
    print ("-f to force overwrite object xml file")
    print ("-c to specify the character")
    print ("-a to specify the asset path")

    argv = sys.argv
    argv = argv[1:]

    print (argv)
    git_root = subprocess.getoutput(git_root_cmd)
    print (git_root)

    raw_asset_path = '/Users/golden/Downloads/game_resource/Life_Is_Strange_1/'
    os.system('rm ' + mat_error_file)

    input_model = argv[0]
    asset_output_path = argv[1]
    b_overwrite = False
    b_character = False

    for idx, arg in enumerate(argv):
        if arg == '-f':
            b_overwrite = True
        if arg == '-c':
            b_character = True
        if arg == '-a':
            raw_asset_path = argv[idx+1]

    print (raw_asset_path)

    file_name_without_ext = os.path.splitext(input_model)[0]
    output_model_name = os.path.basename(file_name_without_ext)

    #output_folder = output_path + output_model_name + '/'
    output_folder = git_root + '/bin/' + asset_output_folder + asset_output_path + output_model_name + '/'

    print ('output_folder=' + output_folder)

    prepare_dir (output_folder)

    output_model = output_folder + output_model_name +  ".mdl"
    output_txt = output_folder + output_model_name +  ".txt"

    if not b_overwrite and os.path.exists(output_model):
        print (output_model + " already exist")
        quit()

    tool = git_root + assimp_tool

    run_cmd = tool + " model " + input_model + " " + output_model + " " + model_args
    print (run_cmd)
    os.system(run_cmd)

    with open(mat_template_file) as f:
        mat_template = f.read()

    if b_character:
        with open(character_template_file) as f:
            obj_template = f.read()
    else:
        with open(obj_template_file) as f:
            obj_template = f.read()

    # print (mat_template)

    with open(output_txt) as f:
        mat_list = f.read().splitlines()

    #os.system('rm ' + output_txt)
    mat_error_happened = False

    for idx, mat_file in enumerate(mat_list):
        mat_name = os.path.splitext(mat_file)[0]
        mat_name = os.path.basename(mat_name)

        new_mat_name = process_material(mat_name, output_folder,
                                      output_model_name, mat_template,
                                      asset_output_path, b_character,
                                      b_overwrite, raw_asset_path)

        mat_list[idx] = 'Materials/' + new_mat_name + '.xml'

        if os.path.exists(mat_error_file):
            mat_error_happened = True
            break

    process_object(output_model_name, output_folder, output_model_name,
                   obj_template, mat_list, b_overwrite, asset_output_path)

    if mat_error_happened:
        os.system('rm -rf ' + output_folder)


#!/usr/bin/python3

import sys
import os
import glob
import subprocess

model_args = "-mb 64 -t -np -na -l"
assimp_tool = "/build_osx/bin/tool/AssetImporter"
git_root_cmd = "git rev-parse --show-toplevel"
output_path = './export/'
raw_asset_path = '/Users/golden/Downloads/game_resource/batman/'
mat_template_file1 = './mat_template_1.xml'

def prepare_dir(dir):
    os.system("mkdir -p " + dir)

def process_material(mat_name, output_folder, output_model_name, mat_template1):
    print ("processing material " + mat_name)

    search_pat = raw_asset_path + '**/' + mat_name + '*.mat'
    mat_files = glob.glob(search_pat, recursive=True)

    if len(mat_files) == 0:
        return

    mat_file = mat_files[0]

    diff = None
    specular = None
    normal = None
    emissive = None

    tech = "Diff"

    mat_path = os.path.dirname(mat_file)

    with open(mat_file, "r") as text_file:
        tex_list = text_file.read().splitlines()

    #print (tex_list)

    for tex_line in tex_list:
        tex_words = tex_line.split('=')

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

    #print (mat_path)
    diff = find_texture(mat_path, diff)
    normal = find_texture(mat_path, normal)
    specular = find_texture(mat_path, specular)
    emissive = find_texture(mat_path, emissive)

    output_texture_folder = output_folder + "Textures/"
    texture_base_path = output_model_name + "/Textures/"

    if diff:
        os.system('cp -f ' + diff + ' ' + output_texture_folder)
        diff = texture_base_path +  os.path.basename(diff)
    else:
        diff = "BaseWhite"

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

    mat_text = mat_template1.replace('@tech', tech)
    if diff:
        mat_text = mat_text.replace('@diffuse', diff)
    if normal:
        mat_text = mat_text.replace('@normal', normal)
    if specular:
        mat_text = mat_text.replace('@specular', specular)
    if emissive:
        mat_text = mat_text.replace('@emissive', emissive)

    #print (mat_text)
    mat_lines = mat_text.splitlines()

    output_mat_file = output_folder + 'Materials/' + mat_name + '.xml';
    #print (output_mat_file)

    with open(output_mat_file, 'w') as output_mat:
        for mat_line in mat_lines:
            if '@' in mat_line:
                continue
            output_mat.write(mat_line + '\n')


def find_texture(mat_path, text_name):
    if not text_name:
        return None

    search_pat = mat_path + '/../' + '**/' + text_name + '.tga'
    #print (search_pat)
    diff_list = glob.glob(search_pat, recursive=True)
    if len(diff_list) > 0:
        ret = diff_list[0]
    else:
        ret = None
    return ret

if __name__ == "__main__":
    print (sys.argv)

    input_model = sys.argv[1]

    file_name_without_ext = os.path.splitext(input_model)[0]
    output_model_name = os.path.basename(file_name_without_ext)

    output_folder = output_path + output_model_name + '/'

    prepare_dir (output_folder)

    output_model = output_folder + output_model_name +  ".mdl"
    output_txt = output_folder + output_model_name +  ".txt"

    git_root = subprocess.getoutput(git_root_cmd)
    print (git_root)
    tool = git_root + assimp_tool

    run_cmd = tool + " model " + input_model + " " + output_model + " " + model_args
    print (run_cmd)
    os.system(run_cmd)

    with open(mat_template_file1) as f:
        mat_template1 = f.read()

    # print (mat_template1)

    with open(output_txt) as f:
        mat_list = f.read().splitlines()

    for mat_file in mat_list:
        mat_name = os.path.splitext(mat_file)[0]
        mat_name = os.path.basename(mat_name)

        process_material(mat_name, output_folder, output_model_name, mat_template1)


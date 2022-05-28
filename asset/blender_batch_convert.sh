#!/usr/bin/env bash

folder_name=$1
BLENDER='/Applications/Blender.app/Contents/MacOS/Blender'
output_folder='/Users/golden/Documents/fbx_objects'
blender_file='/Users/golden/Documents/userpref.blend'

mkdir -p $output_folder

$BLENDER --background --python ./blender_batch_convert.py -- $folder_name $output_folder
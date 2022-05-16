#!/usr/bin/env bash


root_folder=/Users/golden/Downloads/game_resource/batman_knight/
input_folder=/Users/golden/Downloads/game_resource/batman_knight/UmodelExport_BMGame

./merge_images.py $input_folder/Challenge_\*/\*.tga $root_folder/Challenge_images image
./merge_images.py $input_folder/showcase_ui_\*/\*.tga $root_folder/showcase_ui_images image
./merge_images.py $input_folder/Showcase_UI_\*/\*.tga $root_folder/showcase_ui_images image
./merge_images.py $input_folder/wheel_\*/\*.tga $root_folder/wheel_images image
./merge_images.py $input_folder/PhotoFrame\*/\*.tga $root_folder/other_images image
./merge_images.py $input_folder/pcthumb\*/\*.tga $root_folder/other_images image
./merge_images.py $input_folder/pcimage\*/\*.tga $root_folder/other_images image

./merge_images.py $input_folder/concept_\*/ConceptGallery/\*.tga $root_folder/concept_images image
./merge_images.py $input_folder/cs_story\*/\*.tga $root_folder/other_images image

./merge_images.py $input_folder/HudModule\*/\*.tga $root_folder/other_images image
./merge_images.py $input_folder/Backscreen\*/\*.tga $root_folder/other_images image

./merge_images.py $input_folder/gad_\*/\*.tga $root_folder/other_images image
./merge_images.py $input_folder/GAD_\*/\*.tga $root_folder/other_images image

./merge_images.py $input_folder/FE_\*/\*.tga $root_folder/other_images image

rm -rf $input_folder/Challenge_*
rm -rf $input_folder/PhotoFrame*
rm -rf $input_folder/showcase_ui_*
rm -rf $input_folder/pcthumb*
rm -rf $input_folder/pcimage*
rm -rf $input_folder/wheel_*
rm -rf $input_folder/Showcase_UI_*
rm -rf $input_folder/concept_*
rm -rf $input_folder/cs_story*
rm -rf $input_folder/HudModule*
rm -rf $input_folder/Backscreen*
rm -rf $input_folder/gad_*
rm -rf $input_folder/GAD_*
rm -rf $input_folder/FE_*


./merge_images.py $input_folder/VFX_\*/\*\*/\*.tga $root_folder/vfx_images image
rm -rf $input_folder/VFX_*


input_folder=/Users/golden/Downloads/game_resource/batman_knight/UmodelExport_DLC
./merge_images.py $input_folder/HudModule\*/\*.tga $root_folder/other_images image
rm -rf $input_folder/HudModule*





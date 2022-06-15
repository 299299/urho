#!/usr/bin/env bash

cur_path=$(pwd)

#echo $cur_path

gitroot=$(git rev-parse --show-toplevel)
#echo $gitroot
tool=$gitroot/build_osx/bin/tool/AssetImporter

#echo $tool

input_model=$1
filename=$(basename -- "$input_model")
extension="${filename##*.}"
filename="${filename%.*}"
output_filename=export/$filename.mdl

#output_path=$cur_path/

mkdir -p export/

$tool model $input_model $output_filename -mb 64 -t -np -na -l

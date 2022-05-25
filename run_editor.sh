#!/usr/bin/env bash

cd build_osx
make -j8
if [ $? -eq 0 ]; then
    echo 'BUILD OK'
    cd bin
    ./Editor.sh
else
    echo 'BUILD FAIL'
fi

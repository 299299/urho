./cmake_ios.sh .build_ios -DURHO3D_PHYSICS=1 -DURHO3D_LUA=0 -DURHO3D_URHO2D=0 -DURHO3D_NETWORK=0 \
                          -DURHO3D_NAVIGATION=1 -DURHO3D_TOOLS=1 -DURHO3D_SAMPLES=0 -DURHO3D_EXTRAS=0 \
                          -DURHO3D_FILEWATCHER=0 -DURHO3D_ANGELSCRIPT=1 -DCLOCK_GETTIME=0 "$@"
// ==================================================================
//
//    ANIMATION Process Script
//
// ==================================================================

const String OUT_DIR = "GameData/";
const String ASSET_DIR = "Asset/";
const int MAX_BONES = 64; //75
const Array<String> MODEL_ARGS = {"-na", "-l", "-cm", "-ct", "-nm", "-nt", "-mb", String(MAX_BONES), "-np", "-s", "Gundummy02"}; //"-t",
const Array<String> ANIMATION_ARGS = {"-nm", "-nt", "-mb", String(MAX_BONES), "-np", "-s", "Gundummy02"};
String animationInFile;
String animationOutFile;
String mode;
String rotateBoneName = "Bip01_$AssimpFbx$_PreRotation";
String mirrorBoneLKeyword = "Bip01_L";
String mirrorBoneRKeyword = "Bip01_R";
String translateBoneName  = "Bip01_$AssimpFbx$_Translation";

void PreProcess()
{
    Array<String>@ arguments = GetArguments();
    for (uint i=0; i<arguments.length; ++i)
    {
        if (arguments[i] == "-i")
            animationInFile = arguments[i + 1];
        if (arguments[i] == "-o")
            animationOutFile = arguments[i + 1];
        if (arguments[i] == "-m")
            mode = arguments[i + 1];
    }
}

void DoProcess()
{
    if (animationInFile == "" || mode == "")
    {
        Print ("Usage: Urho3DPlayer AnimationProcess.as -i $animation_input -o $animation_output -m $mode (mirror, flip_z) ");
        return;
    }

    Animation@ anim = cache.GetResource("Animation", animationInFile);
    if (anim is null)
    {
        Print ("can not find animation: " + animationInFile);
        return;
    }

    if (mode == "flipz")
    {
        animationOutFile = GetPath(animationInFile) + GetFileName(animationInFile) + "_flipz.ani";
        ProcessFlipZ(anim);
    }
    else if (mode.StartsWith("mirror"))
    {
        animationOutFile = GetPath(animationInFile) + GetFileName(animationInFile) + "_mirror.ani";
        ProcessMirror(anim);
    }

    Print ("Saving " + animationOutFile);

    return;
}

AnimationKeyFrame MirrorKeyframe(AnimationKeyFrame kf_)
{
    const Vector4 rot_(1, 1, -1, -1);
    const Vector3 t_(1, 1, -1);

    AnimationKeyFrame kf(kf_);
    kf.position = kf.position * t_;
    kf.rotation.x *= rot_.x;
    kf.rotation.y *= rot_.y;
    kf.rotation.z *= rot_.z;
    kf.rotation.w *= rot_.w;
    return kf;
}

AnimationKeyFrame MirrorKeyframe2(AnimationKeyFrame kf_)
{
    const Vector4 rot_(-1, -1, -1, -1);
    const Vector3 t_(-1, -1, -1);

    AnimationKeyFrame kf(kf_);
    kf.position = kf.position * t_;
    kf.rotation.x *= rot_.x;
    kf.rotation.y *= rot_.y;
    kf.rotation.z *= rot_.z;
    kf.rotation.w *= rot_.w;
    return kf;
}


void SwapAnimationTrack(AnimationTrack@ l_track, AnimationTrack@ r_track)
{
    // Print ("Swap " + l_track.name + " with " + r_track.name);
    for (uint i=0; i<l_track.numKeyFrames; ++i)
    {
        AnimationKeyFrame l_kf(l_track.keyFrames[i]);
        AnimationKeyFrame r_kf(r_track.keyFrames[i]);
        AnimationKeyFrame temp_kf = l_kf;
        l_kf.position = r_kf.position;
        l_kf.rotation = r_kf.rotation;
        r_kf.position = temp_kf.position;
        r_kf.rotation = temp_kf.rotation;
        l_track.keyFrames[i] = MirrorKeyframe(l_kf);
        r_track.keyFrames[i] = MirrorKeyframe(r_kf);
    }
}

void ProcessMirror(Animation@ anim)
{
    for (uint i=0; i<anim.numTracks; ++i)
    {
        AnimationTrack@ l_track = anim.GetTrack(i);

        // if (l_track.name.StartsWith("Bip01_$AssimpFbx$_"))
        //     continue;
        // if (l_track.name.StartsWith("Bip01_$AssimpFbx$_"))
        //     continue;

        // if (l_track.name == "Bip01")
        //     continue;
        // if (l_track.name == "Bip01_Pelvis")
        //     continue;

        String l_bone_name = l_track.name;
        if (l_bone_name.StartsWith(mirrorBoneLKeyword))
        {
            String r_bone_name = l_bone_name;
            r_bone_name.Replace(mirrorBoneLKeyword, mirrorBoneRKeyword);
            AnimationTrack@ r_track = anim.tracks[r_bone_name];
            if (r_track is null)
            {
                Print (r_bone_name + " not exist!");
                continue;
            }
            SwapAnimationTrack(l_track, r_track);
            // Print ("Swap track");
        }
        else if (l_bone_name.StartsWith(mirrorBoneRKeyword))
        {
        }
        else if (l_track.name == "Bip01_Pelvis")
        {
            for (uint j=0; j<l_track.numKeyFrames; ++j)
            {
                AnimationKeyFrame l_kf(l_track.keyFrames[j]);
                l_track.keyFrames[j] = MirrorKeyframe2(l_kf);
            }
        }
        else if (l_track.name == "")
        else
        {
            for (uint j=0; j<l_track.numKeyFrames; ++j)
            {
                AnimationKeyFrame l_kf(l_track.keyFrames[j]);
                l_track.keyFrames[j] = MirrorKeyframe(l_kf);
            }
        }
    }

    AnimationTrack@ t_track = anim.tracks[translateBoneName];
    if (t_track !is null)
    {
        for (uint i=0; i<t_track.numKeyFrames; ++i)
        {
            AnimationKeyFrame kf(t_track.keyFrames[i]);
            kf.position.x = -kf.position.x;
            t_track.keyFrames[i] = kf;
        }
    }

    anim.Save(animationOutFile);
}

void ProcessFlipZ(Animation@ anim)
{
    AnimationTrack@ track = anim.tracks[rotateBoneName];
    if (track is null)
    {
        Print ("can not find bone: " + rotateBoneName);
        return;
    }

    for (uint i=0; i<track.numKeyFrames; ++i)
    {
        AnimationKeyFrame kf(track.keyFrames[i]);


    }

    anim.Save(animationOutFile);
}


void PostProcess()
{

}

void Start()
{
    uint startTime = time.systemTime;
    PreProcess();
    DoProcess();
    PostProcess();
    engine.Exit();
    uint timeSec = (time.systemTime - startTime) / 1000;
    String timeMsg = (timeSec > 60) ? (String(float(timeSec)/60.0f) + " min") : (String(timeSec) + " sec");
    Print("ANIMATION PROCESS Total Time cost = " + String(timeSec) + " sec");
}


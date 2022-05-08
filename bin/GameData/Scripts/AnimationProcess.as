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

    return;
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
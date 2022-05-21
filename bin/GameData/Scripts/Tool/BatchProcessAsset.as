// ==================================================================
//
//    Batch Process Asset Script for automatic pipeline
//
// ==================================================================

const String OUT_DIR = "TestData/";
const String ASSET_DIR = "ExportData/";
const int MAX_BONES = 64; //75
const Array<String> MODEL_ARGS = {"-na", "-l", "-cm", "-ct", "-nm", "-nt",
                                  "-mb", String(MAX_BONES), "-np", "-s",
                                  "Gundummy02", "Gundummy", "Bip01_Point_Gauntlet_Screen",
                                  "-t"}; //"-t",
const Array<String> ANIMATION_ARGS = {"-nm", "-nt", "-mb", String(MAX_BONES), "-np", "-s",
                                      "Gundummy02", "Gundummy", "Bip01_Point_Gauntlet_Screen"};
String exportFolder;

const int EXPORT_MDL = 0;
const int EXPORT_ANI = 1;

void PreProcess()
{
    Array<String>@ arguments = GetArguments();
    for (uint i=0; i<arguments.length; ++i)
    {
        if (arguments[i] == "-folder")
            exportFolder = arguments[i + 1];
    }

    // Print("exportFolder=" + exportFolder);
    fileSystem.CreateDir(OUT_DIR + "Models");
    fileSystem.CreateDir(OUT_DIR + "Animations");
}

String DoProcess(const String&in name, const String&in folderName, int mode, bool checkExist)
{
    String fName = folderName + name;
    String iname = ASSET_DIR + fName;
    uint pos = name.FindLast('.');
    String oname = OUT_DIR + folderName + name.Substring(0, pos);
    if (mode == EXPORT_MDL)
        oname += ".mdl";
    if (mode == EXPORT_ANI)
        oname += ".ani";
    pos = oname.FindLast('/');
    String outFolder = oname.Substring(0, pos);
    fileSystem.CreateDir(outFolder);

    bool is_windows = GetPlatform() == "Windows";
    if (is_windows) {
        iname.Replace("/", "\\");
        oname.Replace("/", "\\");
    }


    if (checkExist)
    {
        if (fileSystem.FileExists(oname))
        {
            Print ("File " + oname + " exist!");
            return "";
        }
    }

    Array<String> runArgs;
    if (mode == EXPORT_MDL)
        runArgs.Push("model");
    else if (mode == EXPORT_ANI)
        runArgs.Push("anim");
    runArgs.Push("\"" + iname + "\"");
    runArgs.Push("\"" + oname + "\"");

    if (mode == EXPORT_MDL)
    {
        for (uint i=0; i<MODEL_ARGS.length; ++i)
            runArgs.Push(MODEL_ARGS[i]);
    }
    else if (mode == EXPORT_ANI)
    {
        for (uint i=0; i<ANIMATION_ARGS.length; ++i)
            runArgs.Push(ANIMATION_ARGS[i]);
    }

    //for (uint i=0; i<runArgs.length; ++i)
    //    Print("args[" + i +"]=" + runArgs[i]);

    int ret = fileSystem.SystemRun(fileSystem.programDir + "tool/AssetImporter", runArgs);
    if (ret != 0)
        Print("DoProcess " + name + " ret=" + ret);

    return oname;
}

void ProcessModels()
{
    Array<String> models = fileSystem.ScanDir(ASSET_DIR + "Models", "*.*", SCAN_FILES, true);
    for (uint i=0; i<models.length; ++i)
    {
        // Print("Found a model " + models[i]);
        DoProcess(models[i], "Models/", EXPORT_MDL, true);
    }
}

void ProcessAnimations()
{
    Array<String> animations = fileSystem.ScanDir(ASSET_DIR + "Animations", "*.*", SCAN_FILES, true);
    for (uint i=0; i<animations.length; ++i)
    {
        // Print("Found a animation " + animations[i]);
        DoProcess(animations[i], "Animations/", EXPORT_ANI, true);
    }
}

void PostProcess()
{

}

void Start()
{
    uint startTime = time.systemTime;
    PreProcess();
    ProcessModels();
    ProcessAnimations();
    PostProcess();
    engine.Exit();
    uint timeSec = (time.systemTime - startTime) / 1000;
    String timeMsg = (timeSec > 60) ? (String(float(timeSec)/60.0f) + " min") : (String(timeSec) + " sec");
    Print("BATCH PROCESS Total Time cost = " + String(timeSec) + " sec");
}
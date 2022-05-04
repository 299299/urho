// ==============================================
//
//    All rendering related functions
//
// ==============================================
enum RenderFeature
{
    RF_NONE     = 0,
    RF_SHADOWS  = (1 << 0),
    RF_HDR      = (1 << 1),
    RF_FULL     = RF_SHADOWS | RF_HDR,
};

bool bHdr = true;
int colorGradingIndex = 0;
int render_features = RF_FULL;
String LUT = "";
const String UI_FONT = "Fonts/GAEN.ttf";
int UI_FONT_SIZE = 20;

int FindRenderCommand(RenderPath@ path, const String&in tag)
{
    for (uint i=0; i<path.numCommands; ++i)
    {
        if (path.commands[i].tag == tag)
            return i;
    }
    return -1;
}

void ChangeRenderCommandTexture(RenderPath@ path, const String&in tag, const String&in texture, TextureUnit unit)
{
    int i = FindRenderCommand(path, tag);
    if (i < 0)
    {
        Print("Can not find renderpath tag " + tag);
        return;
    }

    RenderPathCommand cmd = path.commands[i];
    cmd.textureNames[unit] = texture;
    path.commands[i] = cmd;
}


void SetColorGrading(int index)
{
    Array<String> colorGradingTextures =
    {
        "Weathered",
        "Hipster",
        "Vintage",
        "Hollywood",
        "BleachBypass",
        "CrossProcess",
        "Dream",
        "Negative",
        "Rainbow",
        "Posterize",
        "Noire",
        "SciFi",
        "SinCity",
        "Saw",
        "Sepia",
        "1960",
        "Action",
        "AlienInvasion",
        "BadFilm",
        "Beach",
        "Cyberpunk",
        "Dark",
        "DayForNight",
        "Documentary",
        "FinalBattle",
        "Fire",
        "Flashback",
        "Hackers",
        "HeatSignature",
        "Hitchcock",
        "AlienWorld",
        "Horror",
        "HotSun",
        "Intensity",
        "Matrix",
        "Millennium",
        "MusicVideo",
        "OldCountry",
        "OrangeTeal",
        "PurpleHaze",
        "RedAndBlue",
        "RedRoom",
        "RobotVision",
        "Romantic",
        "TexMex",
        "Toxic",
        "TritonePurple",
        "Underwater",
        "War",
        "Warm",
        "LUTIdentity"
    };
    int len = int(colorGradingTextures.length);
    if (index >= len)
        index = 0;
    if (index < 0)
        index = len - 1;
    colorGradingIndex = index;
    LUT = colorGradingTextures[index];
    ChangeRenderCommandTexture(renderer.viewports[0].renderPath, "ColorCorrection", "Textures/LUT/" + LUT + ".xml", TU_VOLUMEMAP);
}

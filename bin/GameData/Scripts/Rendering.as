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

int render_features = RF_FULL;
String LUT = "";
bool bHdr = true;

void CreateViewPort()
{
    Viewport@ viewport = Viewport(null, null);
    renderer.viewports[0] = viewport;

    bHdr = render_features & RF_HDR != 0;
    renderer.hdrRendering = bHdr;

    RenderPath@ renderpath = viewport.renderPath.Clone();
    if (bHdr)
    {
        // if (reflection)
        //    renderpath.Load(cache.GetResource("XMLFile","RenderPaths/ForwardHWDepth.xml"));
        // else
        renderpath.Load(cache.GetResource("XMLFile","RenderPaths/ForwardDepth.xml")); //ForwardDepth
        renderpath.Append(cache.GetResource("XMLFile","PostProcess/AutoExposure.xml"));
        renderpath.Append(cache.GetResource("XMLFile","PostProcess/BloomHDR.xml"));
        renderpath.Append(cache.GetResource("XMLFile","PostProcess/Tonemap.xml"));
        renderpath.SetEnabled("TonemapReinhardEq3", false);
        renderpath.SetEnabled("TonemapUncharted2", true);
        renderpath.shaderParameters["TonemapMaxWhite"] = 1.8f;
        renderpath.shaderParameters["TonemapExposureBias"] = 2.5f;
        renderpath.shaderParameters["AutoExposureAdaptRate"] = 2.0f;
        renderpath.shaderParameters["BloomHDRMix"] = Variant(Vector2(0.9f, 0.6f));
    }
    renderpath.Append(cache.GetResource("XMLFile", "PostProcess/FXAA2.xml"));
    // renderpath.Append(cache.GetResource("XMLFile","PostProcess/ColorCorrection.xml"));

    if (bHdr)
        renderpath.Append(cache.GetResource("XMLFile", "PostProcess/GammaCorrection.xml"));
    viewport.renderPath = renderpath;
}

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

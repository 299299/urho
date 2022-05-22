
enum LoadSubState
{
    LOADING_RESOURCES,
    LOADING_MOTIONS,
    LOADING_FINISHED,
};

class LoadingState : GameState
{
    int                 state = -1;
    int                 numLoadedResources = 0;
    Scene@              preloadScene;
    float               loadingTestTime = 10.0;

    Gif@                loadingGif;

    LoadingState()
    {
        SetName("LoadingState");
    }

    void CreateLoadingUI()
    {
        float alphaDuration = 1.0f;
        ValueAnimation@ alphaAnimation = ValueAnimation();
        alphaAnimation.SetKeyFrame(0.0f, Variant(0.0f));
        alphaAnimation.SetKeyFrame(alphaDuration, Variant(1.0f));
        alphaAnimation.SetKeyFrame(alphaDuration * 2, Variant(0.0f));

        Texture2D@ logoTexture = cache.GetResource("Texture2D", "Textures/LogoLarge.png");
        Sprite@ logoSprite = ui.root.CreateChild("Sprite", "logo");
        logoSprite.texture = logoTexture;
        int textureWidth = logoTexture.width;
        int textureHeight = logoTexture.height;
        logoSprite.SetScale(256.0f / textureWidth);
        logoSprite.SetSize(textureWidth, textureHeight);
        logoSprite.SetHotSpot(0, textureHeight);
        logoSprite.SetAlignment(HA_LEFT, VA_BOTTOM);
        logoSprite.SetPosition(graphics.width - textureWidth/2, 0);
        logoSprite.opacity = 0.75f;
        logoSprite.priority = -100;
        logoSprite.AddTag(TAG_LOADING);

        Text@ text = ui.root.CreateChild("Text", "loading_text");
        text.SetFont(cache.GetResource("Font", UI_FONT), UI_FONT_SIZE);
        text.SetAlignment(HA_LEFT, VA_BOTTOM);
        text.SetPosition(2, 0);
        text.color = Color(1, 1, 1);
        text.textEffect = TE_STROKE;
        text.AddTag(TAG_LOADING);

        // Texture2D@ loadingTexture = cache.GetResource("Texture2D", "Textures/Loading.tga");
        // Sprite@ loadingSprite = ui.root.CreateChild("Sprite", "loading_bg");
        // loadingSprite.texture = loadingTexture;
        // textureWidth = loadingTexture.width;
        // textureHeight = loadingTexture.height;
        // loadingSprite.SetSize(textureWidth, textureHeight);
        // loadingSprite.SetPosition(graphics.width/2 - textureWidth/2, graphics.height/2 - textureHeight/2);
        // loadingSprite.priority = -100;
        // loadingSprite.opacity = 0.0f;
        // loadingSprite.AddTag(TAG_LOADING);
        // loadingSprite.SetAttributeAnimation("Opacity", alphaAnimation);

        if (loadingGif is null)
            @loadingGif = Gif("UI/Loading", 20, 256, 0.1, true);
        loadingGif.Start();
    }

    void Enter(State@ lastState)
    {
        State::Enter(lastState);
        CreateLoadingUI();
        ChangeSubState(LOADING_RESOURCES);
    }

    void Exit(State@ nextState)
    {
        State::Exit(nextState);
        Array<UIElement@>@ elements = ui.root.GetChildrenWithTag(TAG_LOADING);
        for (uint i = 0; i < elements.length; ++i)
            elements[i].Remove();
        loadingGif.Stop();
    }

    void Update(float dt)
    {
        Text@ text = ui.root.GetChild("loading_text");
        if (state == LOADING_RESOURCES)
        {

        }
        else if (state == LOADING_MOTIONS)
        {
            if (text !is null)
                text.text = "Loading Motions, loaded = " + gMotionMgr.processedMotions;

            if (d_log)
                LogPrint("============================== Motion Loading start ==============================");

            if (gMotionMgr.Update(dt))
            {
                gMotionMgr.Finish();
                ChangeSubState(LOADING_FINISHED);
                if (text !is null)
                    text.text = "Loading Scene Resources";
            }

            if (d_log)
                LogPrint("============================== Motion Loading end ==============================");
        }
        else if (state == LOADING_FINISHED)
        {
            if (preloadScene !is null)
                preloadScene.Remove();
            preloadScene = null;
            text.text = "Loading Finished";


            if (timeInState > loadingTestTime)
            {
                gGame.ChangeState("TestGameState");
            }
        }

        if (loadingGif !is null)
            loadingGif.Update(dt);

        GameState::Update(dt);
    }

    void ChangeSubState(int newState)
    {
        if (state == newState)
            return;

        LogPrint("LoadingState ChangeSubState from " + state + " to " + newState);
        state = newState;

        if (newState == LOADING_RESOURCES)
        {
            preloadScene = Scene();
            preloadScene.LoadAsyncXML(cache.GetFile(preload_scene_name), LOAD_RESOURCES_ONLY);
        }
        else if (newState == LOADING_MOTIONS)
            gMotionMgr.Start();
    }

    void OnSceneLoadFinished(Scene@ _scene)
    {
        if (state == LOADING_RESOURCES)
        {
            LogPrint("Scene Loading Finished");
            ChangeSubState(LOADING_MOTIONS);
        }
    }

    void OnAsyncLoadProgress(Scene@ _scene, float progress, int loadedNodes, int totalNodes, int loadedResources, int totalResources)
    {
        Text@ text = ui.root.GetChild("loading_text");
        if (text !is null)
            text.text = "Loading scene ressources progress=" + progress + " resources:" + loadedResources + "/" + totalResources;
    }
};


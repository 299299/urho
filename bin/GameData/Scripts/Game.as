// ==============================================
//
//    GameState Class for Game Manager
//
// ==============================================

class GameState : State
{
    String nextStateName;

    void OnSceneLoadFinished(Scene@ _scene)
    {
    }

    void OnAsyncLoadProgress(Scene@ _scene, float progress, int loadedNodes, int totalNodes, int loadedResources, int totalResources)
    {
    }

    void OnKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
        {
             if (!console.visible)
                OnESC();
            else
                console.visible = false;
        }
    }

    void OnESC()
    {
        engine.Exit();
    }

    void OnSceneTimeScaleUpdated(Scene@ scene, float newScale)
    {
    }

    void Finish()
    {
        gGame.ChangeState(nextStateName);
    }
};

class TestState : GameState
{
    TestState()
    {
        SetName("TestState");
    }
};

class SceneLoadingState : GameState
{
    int                 numLoadedResources = 0;
    Scene@              preloadScene;
    String              preLoadSceneName;
    bool                resourceOnly = true;

    SceneLoadingState()
    {
        SetName("SceneLoadingState");
    }

    void Enter(State@ lastState)
    {
        State::Enter(lastState);
        if (!engine.headless)
            CreateLoadingUI();

        if (preloadScene is null)
        {
            @preloadScene = Scene();
            preloadScene.LoadAsyncXML(cache.GetFile(preLoadSceneName),
                                      resourceOnly ? LOAD_RESOURCES_ONLY : LOAD_SCENE_AND_RESOURCES);
        }
    }

    void Exit(State@ nextState)
    {
        State::Exit(nextState);
        if (!engine.headless)
            DestroyLoadingUI();
    }

    void OnAsyncLoadProgress(Scene@ _scene, float progress, int loadedNodes, int totalNodes, int loadedResources, int totalResources)
    {
        Text@ text = ui.root.GetChild("loading_text");
        if (text !is null)
            text.text = "Loading scene ressources progress=" + progress + " resources:" + loadedResources + "/" + totalResources;
    }

    void OnSceneLoadFinished()
    {
        Finish();
    }

    void OnESC()
    {
        preloadScene.StopAsyncLoading();
        GameState::OnESC();
    }
};


class MotionLoadingState : GameState
{
    MotionLoadingState()
    {
        SetName("MotionLoadingState");
        nextStateName = "InGameState";
    }

    void Enter(State@ lastState)
    {
        State::Enter(lastState);
        if (!engine.headless)
            CreateLoadingUI();

        if (gMotionMgr !is null)
            gMotionMgr.Start();
    }

    void Update(float dt)
    {
        Text@ text = ui.root.GetChild("loading_text");
        text.text = "Loading Motions, loaded = " + gMotionMgr.processedMotions;
        if (d_log)
            Print("============================== Motion Loading start ==============================");

        if (gMotionMgr.Update(dt))
        {
            gMotionMgr.Finish();
            Finish();
        }

        if (d_log)
            Print("============================== Motion Loading end ==============================");
    }
};

enum GameSubState
{
    GAME_FADING,
    GAME_RUNNING,
    GAME_PAUSE,
};

class InGameState : GameState
{
    Scene@              gameScene;
    String              sceneName;
    BorderImage@        fullscreenUI;

    int                 state = -1;

    float               fadeTime;
    float               fadeInDuration = 2.0f;

    bool                postInited = false;

    Array<uint>         gameObjects;

    InGameState()
    {
        SetName("InGameState");
        fullscreenUI = BorderImage("FullScreenImage");
        fullscreenUI.visible = false;
        fullscreenUI.priority = -9999;
        fullscreenUI.opacity = 1.0f;
        fullscreenUI.texture = cache.GetResource("Texture2D", "Textures/fade.png");
        fullscreenUI.SetFullImageRect();
        if (!engine.headless)
            fullscreenUI.SetFixedSize(graphics.width, graphics.height);
        ui.root.AddChild(fullscreenUI);
    }

    ~InGameState()
    {
        // gameScene = null;
        fullscreenUI.Remove();
    }

    void Enter(State@ lastState)
    {
        state = -1;
        State::Enter(lastState);

        if (!engine.headless)
        {
            CreateViewPort();
            CreateGameUI();
        }

        CreateScene();
        PostCreate();

        ChangeSubState(GAME_FADING);
    }

    void PostCreate()
    {
        Node@ zoneNode = gameScene.GetChild("zone", true);
        Zone@ zone = zoneNode.GetComponent("Zone");
        // zone.heightFog = false;
    }

    void CreateGameUI()
    {
        int height = graphics.height / 22;
        if (height > 64)
            height = 64;
        Text@ messageText = ui.root.CreateChild("Text", "message");
        messageText.SetFont(cache.GetResource("Font", UI_FONT), UI_FONT_SIZE);
        messageText.SetAlignment(HA_CENTER, VA_CENTER);
        messageText.SetPosition(0, -height * 2 + 100);
        messageText.color = Color(1, 0, 0);
        messageText.visible = false;
    }

    void Update(float dt)
    {
        switch (state)
        {
        case GAME_FADING:
            {
                float t = fullscreenUI.GetAttributeAnimationTime("Opacity");
                if (t + 0.05f >= fadeTime)
                {
                    fullscreenUI.visible = false;
                    ChangeSubState(GAME_RUNNING);
                }
            }
            break;

        case GAME_RUNNING:
            {
                if (!postInited) {
                    if (timeInState > 2.0f) {
                        postInit();
                        postInited = true;
                    }
                }
            }
            break;
        }
        GameState::Update(dt);
    }

    void ChangeSubState(int newState)
    {
        if (state == newState)
            return;

        int oldState = state;
        Print("InGameState ChangeSubState from " + oldState + " to " + newState);
        state = newState;
        timeInState = 0.0f;

        script.defaultScene.updateEnabled = !(newState == GAME_PAUSE);
        fullscreenUI.SetAttributeAnimationSpeed("Opacity", newState == GAME_PAUSE ? 0.0f : 1.0f);

        Player@ player = GetPlayer();

        switch (newState)
        {
        case GAME_RUNNING:
            {
                freezeInput = false;
            }
            break;

        case GAME_FADING:
            {
                if (oldState != GAME_PAUSE)
                {
                    ValueAnimation@ alphaAnimation = ValueAnimation();
                    alphaAnimation.SetKeyFrame(0.0f, Variant(1.0f));
                    alphaAnimation.SetKeyFrame(fadeInDuration, Variant(0.0f));
                    fadeTime = fadeInDuration;
                    fullscreenUI.visible = true;
                    fullscreenUI.SetAttributeAnimation("Opacity", alphaAnimation, WM_ONCE);
                }

                freezeInput = true;
            }
            break;
        }
    }

    void OnNodeLoaded(Node@ node_)
    {
        Print("node.name=" + node_.name);
    }

    void OnSceneLoaded(Scene@ scene_)
    {
        uint t = time.systemTime;

        gameObjects.Clear();

        // process current scene
        for (uint i=0; i<scene_.numChildren; ++i)
        {
            OnNodeLoaded(scene_.children[i]);
        }

        gCameraMgr.Start(scene_);
        gameScene = scene_;

        renderer.viewports[0].scene = scene_;

        Print("CreateScene() --> total time-cost " + (time.systemTime - t) + " ms.");
    }

    void CreateScene()
    {
        Scene@ scene_ = Scene();
        script.defaultScene = scene_;
        scene_.LoadXML(cache.GetFile(sceneName));
        OnSceneLoaded(scene_);
    }

    void ShowMessage(const String&in msg, bool show)
    {
        Text@ messageText = ui.root.GetChild("message", true);
        if (messageText !is null)
        {
            messageText.text = msg;
            messageText.visible = true;
        }
    }

    void OnKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
        {
            engine.Exit();
            return;
        }
        GameState::OnKeyDown(key);
    }

    String GetDebugText()
    {
        return  " name=" + name + " timeInState=" + timeInState + " state=" + state  + "\n";
    }

    void postInit()
    {
        if (bHdr && graphics !is null)
            renderer.viewports[0].renderPath.shaderParameters["AutoExposureAdaptRate"] = 0.6f;
    }

    void DebugDraw(DebugRenderer@ debug)
    {
        for (uint i=0; i<gameObjects.length; ++i)
        {
            Node@ node_ = gameScene.GetNode(gameObjects[i]);
            if (node_ !is null)
            {
                GameObject@ go = cast<GameObject>(node_.scriptObject);
                if (go !is null)
                    go.DebugDraw(debug);
            }
        }
    }
};

class GameFSM : FSM
{
    GameState@ gameState;

    GameFSM()
    {
        Print("GameFSM()");
    }

    ~GameFSM()
    {
        Print("~GameFSM()");
    }

    void Start()
    {
        // AddState(LoadingState());
        // AddState(TestGameState());
        // ChangeState(states[0].name);
    }

    bool ChangeState(const StringHash&in nameHash)
    {
        bool b = FSM::ChangeState(nameHash);
        if (b)
            @gameState = cast<GameState>(currentState);
        return b;
    }

    void OnSceneLoadFinished(Scene@ _scene)
    {
        if (gameState !is null)
            gameState.OnSceneLoadFinished(_scene);
    }

    void OnAsyncLoadProgress(Scene@ _scene, float progress, int loadedNodes, int totalNodes, int loadedResources, int totalResources)
    {
        if (gameState !is null)
            gameState.OnAsyncLoadProgress(_scene, progress, loadedNodes, totalNodes, loadedResources, totalResources);
    }

    void OnKeyDown(int key)
    {
        if (gameState !is null)
            gameState.OnKeyDown(key);
    }

    void OnSceneTimeScaleUpdated(Scene@ scene, float newScale)
    {
        if (gameState !is null)
            gameState.OnSceneTimeScaleUpdated(scene, newScale);
    }
};
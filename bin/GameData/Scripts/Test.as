#include "Scripts/Constants.as"
// ------------------------------------------------
#include "Scripts/Game.as"
#include "Scripts/AssetProcess.as"
#include "Scripts/Motion.as"
#include "Scripts/Input.as"
#include "Scripts/FSM.as"
#include "Scripts/Camera.as"
#include "Scripts/GameObject.as"
#include "Scripts/Character.as"
#include "Scripts/Player.as"
#include "Scripts/FadeOverlay.as"
#include "Scripts/PhysicsSensor.as"
#include "Scripts/Debug.as"
#include "Scripts/Rendering.as"
#include "Scripts/UI.as"
#include "Scripts/Audio.as"

uint playerId = M_MAX_UNSIGNED;
GameInput@ gInput = GameInput();
bool debugCamera = false;
GameFSM@ gGame = TestGameFSM();

void LoadGlobalVars()
{
    Variant v = GetGlobalVar("Draw_Debug");
    if (!v.empty)
    {
        drawDebug = v.GetInt();
    }

    v = GetGlobalVar("Color_Grading");
    if (!v.empty)
    {
        colorGradingIndex = v.GetInt();
    }

    v = GetGlobalVar("Debug_Camera");
    if (!v.empty)
    {
        debugCamera = v.GetBool();

        gCameraMgr.SetDebugCamera(debugCamera);
        ui.cursor.visible = !debugCamera;
    }
}

void SaveGlobalVars()
{
    SetGlobalVar("Draw_Debug", Variant(drawDebug));
    SetGlobalVar("Color_Grading", Variant(colorGradingIndex));
    SetGlobalVar("Debug_Camera", Variant(debugCamera));
}

void Start()
{
    Print("Game Running Platform: " + GetPlatform());
    // lowend_platform = GetPlatform() != "Windows";

    cache.autoReloadResources = true;
    engine.pauseMinimized = true;
    script.defaultScriptFile = scriptFile;
    if (renderer !is null && (render_features & RF_HDR != 0))
        renderer.hdrRendering = true;

    LoadGlobalVars();
    SetRandomSeed(time.systemTime);
    // @gMotionMgr = LIS_Game_MotionManager();

    if (!engine.headless)
    {
        SetWindowTitleAndIcon();
        CreateConsoleAndDebugHud();
        CreateUI();
    }

    InitAudio();
    SubscribeToEvents();

    gGame.Start();
}

void Stop()
{
    Print("Test Stop");
    if (gMotionMgr !is null)
        gMotionMgr.Stop();
    ui.Clear();
}

Player@ GetPlayer()
{
    Scene@ scene_ = script.defaultScene;
    if (scene_ is null)
        return null;
    Node@ characterNode = scene_.GetNode(playerId);
    if (characterNode is null)
        return null;
    return cast<Player>(characterNode.scriptObject);
}

void SubscribeToEvents()
{
    SubscribeToEvent("Update", "HandleUpdate");
    SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate");
    SubscribeToEvent("KeyDown", "HandleKeyDown");
    SubscribeToEvent("AsyncLoadFinished", "HandleSceneLoadFinished");
    SubscribeToEvent("AsyncLoadProgress", "HandleAsyncLoadProgress");
    SubscribeToEvent("CameraEvent", "HandleCameraEvent");
    SubscribeToEvent("SliderChanged", "HandleSliderChanged");
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    float timeStep = eventData["TimeStep"].GetFloat();

    gInput.Update(timeStep);
    gCameraMgr.Update(timeStep);
    gGame.Update(timeStep);

    DebugUpdate();
}

void HandlePostRenderUpdate(StringHash eventType, VariantMap& eventData)
{
   DebugPostUpdate();
}

void HandleKeyDown(StringHash eventType, VariantMap& eventData)
{
    Scene@ scene_ = script.defaultScene;
    int key = eventData["Key"].GetInt();
    gGame.OnKeyDown(key);
    DebugKey(key);
}

void HandleSceneLoadFinished(StringHash eventType, VariantMap& eventData)
{
    Print("HandleSceneLoadFinished");
    gGame.OnSceneLoadFinished(eventData["Scene"].GetPtr());
}

void HandleAsyncLoadProgress(StringHash eventType, VariantMap& eventData)
{
    Print("HandleAsyncLoadProgress");
    Scene@ _scene = eventData["Scene"].GetPtr();
    float progress = eventData["Progress"].GetFloat();
    int loadedNodes = eventData["LoadedNodes"].GetInt();
    int totalNodes = eventData["TotalNodes"].GetInt();
    int loadedResources = eventData["LoadedResources"].GetInt();
    int totalResources = eventData["TotalResources"].GetInt();
    gGame.OnAsyncLoadProgress(_scene, progress, loadedNodes, totalNodes, loadedResources, totalResources);
}

void HandleCameraEvent(StringHash eventType, VariantMap& eventData)
{
    gCameraMgr.OnCameraEvent(eventData);
}


class TestLoadingState : SceneLoadingState
{
    TestLoadingState()
    {
        preLoadSceneName = "Scenes/Mini Toon Office_Scenes_Toon Office sample Scene.xml";
        nextStateName = "TestInGameState";
    }

    void Update(float dt)
    {
    }
};

class TestInGameState : InGameState
{
    TestInGameState()
    {
        sceneName = "Scenes/Mini Toon Office_Scenes_Toon Office sample Scene.xml";
    }

    void OnNodeLoaded(Node@ node_)
    {
        InGameState::OnNodeLoaded(node_);
    }

    void OnSceneLoaded(Scene@ scene_)
    {
        InGameState::OnSceneLoaded(scene_);
        gCameraMgr.SetCameraController("Fixed");

        Node@ camNode = scene_.GetChild("Main Camera");
        if (camNode !is null)
        {
            gCameraMgr.cameraNode.worldPosition = camNode.worldPosition;
            gCameraMgr.cameraNode.worldRotation = camNode.worldRotation;
        }
    }
};

class TestGameFSM : GameFSM
{
    void Start()
    {
        AddState(TestLoadingState());
        AddState(TestInGameState());
        ChangeState(states[0].name);
    }
}




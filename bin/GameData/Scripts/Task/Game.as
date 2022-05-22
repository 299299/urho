// ==============================================
//
//    GameState Class for Game Manager
//
// ==============================================

class GameState : State
{
    void OnCharacterKilled(Character@ killer, Character@ dead)
    {
    }

    void OnSceneLoadFinished(Scene@ _scene)
    {
    }

    void OnAsyncLoadProgress(Scene@ _scene, float progress, int loadedNodes, int totalNodes, int loadedResources, int totalResources)
    {
    }

    void OnPlayerStatusUpdate(Player@ player)
    {
    }

    void OnSceneTimeScaleUpdated(Scene@ scene, float newScale)
    {
    }
};


class GameFSM : FSM
{
    GameState@ gameState;

    GameFSM()
    {
        LogPrint("GameFSM()");
    }

    ~GameFSM()
    {
        LogPrint("~GameFSM()");
    }

    void Start()
    {
        AddState(LoadingState());
        AddState(TestGameState());
    }

    bool ChangeState(const String&in name)
    {
        bool b = FSM::ChangeState(name);
        if (b)
            @gameState = cast<GameState>(currentState);
        return b;
    }

    void OnCharacterKilled(Character@ killer, Character@ dead)
    {
        if (gameState !is null)
            gameState.OnCharacterKilled(killer, dead);
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

    void OnPlayerStatusUpdate(Player@ player)
    {
        if (gameState !is null)
            gameState.OnPlayerStatusUpdate(player);
    }

    void OnSceneTimeScaleUpdated(Scene@ scene, float newScale)
    {
        if (gameState !is null)
            gameState.OnSceneTimeScaleUpdated(scene, newScale);
    }
};



void Global_SetSceneTimeScale(float scale)
{
    Scene@ _scene = script.defaultScene;
    if (_scene is null)
        return;
    if (_scene.timeScale == scale)
        return;
    _scene.timeScale = scale;
    gGame.OnSceneTimeScaleUpdated(_scene, scale);
    LogPrint("Global SetSceneTimeScale:" + scale);
}

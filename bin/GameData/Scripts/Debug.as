// ==============================================
//
//    All debug related functions
//
// ==============================================
int drawDebug = 0;

void ShootBox(Scene@ _scene)
{
    Node@ cameraNode = gCameraMgr.GetCameraNode();
    Node@ boxNode = _scene.CreateChild("SmallBox");
    boxNode.position = cameraNode.position;
    boxNode.rotation = cameraNode.rotation;
    boxNode.SetScale(1.0);
    StaticModel@ boxObject = boxNode.CreateComponent("StaticModel");
    boxObject.model = cache.GetResource("Model", "Models/Box.mdl");
    boxObject.material = cache.GetResource("Material", "Materials/StoneEnvMapSmall.xml");
    boxObject.castShadows = true;
    RigidBody@ body = boxNode.CreateComponent("RigidBody");
    body.mass = 0.25f;
    body.friction = 0.75f;
    body.collisionLayer = COLLISION_LAYER_PROP;
    CollisionShape@ shape = boxNode.CreateComponent("CollisionShape");
    shape.SetBox(Vector3(1.0f, 1.0f, 1.0f));
    body.linearVelocity = cameraNode.rotation * Vector3(0.0f, 0.25f, 1.0f) * 10.0f;
}

void ShootSphere(Scene@ _scene)
{
    Node@ cameraNode = gCameraMgr.GetCameraNode();
    Node@ sphereNode = _scene.CreateChild("Sphere");
    sphereNode.position = cameraNode.position;
    sphereNode.rotation = cameraNode.rotation;
    sphereNode.SetScale(1.0);
    StaticModel@ boxObject = sphereNode.CreateComponent("StaticModel");
    boxObject.model = cache.GetResource("Model", "Models/Sphere.mdl");
    boxObject.material = cache.GetResource("Material", "Materials/StoneSmall.xml");
    boxObject.castShadows = true;
    RigidBody@ body = sphereNode.CreateComponent("RigidBody");
    body.mass = 1.0f;
    body.rollingFriction = 0.15f;
    body.collisionLayer = COLLISION_LAYER_PROP;
    CollisionShape@ shape = sphereNode.CreateComponent("CollisionShape");
    shape.SetSphere(1.0f);
    body.linearVelocity = cameraNode.rotation * Vector3(0.0f, 0.25f, 1.0f) * 10.0f;
}

void ToggleDebugWindow()
{
    Window@ win = ui.root.GetChild("DebugWindow", true);
    if (win !is null)
    {
        win.Remove();
        input.SetMouseVisible(false);
        freezeInput = false;
        return;
    }

    win = Window();
    win.name = "DebugWindow";
    win.movable = true;
    win.resizable = true;
    win.opacity = 0.8f;
    win.SetLayout(LM_VERTICAL, 2, IntRect(2,4,2,4));
    win.SetAlignment(HA_LEFT, VA_TOP);
    win.SetStyleAuto();
    ui.root.AddChild(win);

    Text@ windowTitle = Text();
    windowTitle.text = "Debug Parameters";
    windowTitle.SetStyleAuto();
    win.AddChild(windowTitle);

    IntVector2 scrSize(graphics.width, graphics.height);
    IntVector2 winSize(scrSize);
    winSize.x = int(float(winSize.x) * 0.3f);
    winSize.y = int(float(winSize.y) * 0.5f);
    win.size = winSize;
    win.SetPosition(5, (scrSize.y - winSize.y)/3);
    input.SetMouseVisible(true);
    freezeInput = true;

    RenderPath@ path = renderer.viewports[0].renderPath;
    UIElement@ parent = win;
    CreateDebugSlider(parent, "TonemapMaxWhite", 0, 0.0f, 5.0f, path.shaderParameters["TonemapMaxWhite"].GetFloat());
    CreateDebugSlider(parent, "TonemapExposureBias", 0, 0.0f, 5.0f, path.shaderParameters["TonemapExposureBias"].GetFloat());
    //CreateDebugSlider(parent, "BloomHDRBlurRadius", 0, 0.0f, 10.0f, path.shaderParameters["BloomHDRBlurRadius"].GetFloat());
    CreateDebugSlider(parent, "BloomHDRMix_x", 1, 0.0f, 1.0f, path.shaderParameters["BloomHDRMix"].GetVector2().x);
    CreateDebugSlider(parent, "BloomHDRMix_y", 2, 0.0f, 5.0f, path.shaderParameters["BloomHDRMix"].GetVector2().y);
}

void CreateDebugSlider(UIElement@ parent, const String&in label, int tag, float min, float max, float cur)
{
    UIElement@ textContainer = UIElement();
    parent.AddChild(textContainer);
    textContainer.layoutMode = LM_HORIZONTAL;
    textContainer.SetStyleAuto();

    Text@ text = Text();
    textContainer.AddChild(text);
    text.text = label + ": ";
    text.SetStyleAuto();

    Text@ valueText = Text();
    textContainer.AddChild(valueText);
    valueText.name = label + "_value";
    valueText.text = String(cur);
    valueText.SetStyleAuto();

    Slider@ slider = Slider();
    slider.name = label;
    slider.SetStyleAuto();
    slider.range = max - min;
    slider.value = cur - min;
    slider.SetMinSize(2, 16);
    slider.vars[RANGE] = Vector2(min, max);
    slider.vars[TAG] = tag;
    parent.AddChild(slider);
}

void HandleSliderChanged(StringHash eventType, VariantMap& eventData)
{
    UIElement@ ui = eventData["Element"].GetPtr();
    float value = eventData["Value"].GetFloat();
    if (!ui.vars.Contains(TAG))
        return;

    Vector2 range = ui.GetVar(RANGE).GetVector2();
    value += range.x;
    int tag = ui.GetVar(TAG).GetInt();
    Text@ valueText = ui.parent.GetChild(ui.name + "_value", true);
    if (valueText !is null)
        valueText.text = String(value);

    RenderPath@ path = renderer.viewports[0].renderPath;

    switch (tag)
    {
    case 0:
        path.shaderParameters[ui.name] = value;
        break;
    case 1:
        {
            Vector2 v = path.shaderParameters["BloomHDRMix"].GetVector2();
            v.x = value;
            path.shaderParameters["BloomHDRMix"] = Variant(v);
        }
        break;
    case 2:
        {
            Vector2 v = path.shaderParameters["BloomHDRMix"].GetVector2();
            v.y = value;
            path.shaderParameters["BloomHDRMix"] = Variant(v);
        }
        break;
    }
}

void ExecuteCommand()
{
    String commands = GetConsoleInput();
    if(commands.length == 0)
        return;

    Print("######### Console Input: [" + commands + "] #############");
    Array<String> command_list = commands.Split(',');
    String command = command_list.empty ? commands : command_list[0];

    if (command == "dump")
    {
        String debugText = "camera position=" + gCameraMgr.GetCameraNode().worldPosition.ToString() + "\n";
        debugText += gInput.GetDebugText();

        Scene@ scene_ = script.defaultScene;
        if (scene_ !is null)
        {
            Array<Node@> nodes = scene_.GetChildrenWithScript("GameObject", true);
            for (uint i=0; i<nodes.length; ++i)
            {
                GameObject@ object = cast<GameObject@>(nodes[i].scriptObject);
                if (object !is null)
                    debugText += object.GetDebugText();
            }
        }
        Print(debugText);
    }
    else if (command == "anim")
    {
        String testName = "BM_Attack/Attack_Close_Forward_02";
        Player@ player = GetPlayer();
        if (player !is null)
            player.TestAnimation(testName);
    }
    else if (command == "stop")
    {
        gMotionMgr.Stop();
        Scene@ scene_ = script.defaultScene;
        if (scene_ is null)
            return;
        scene_.Clear();
    }
}


void DebugUpdate()
{
    if (engine.headless)
        ExecuteCommand();

    if (script.defaultScene is null)
        return;

    if (drawDebug > 0)
    {
        String seperator = "-------------------------------------------------------------------------------------------------------\n";
        String debugText = seperator;
        debugText += gGame.GetDebugText();
        debugText += seperator;
        debugText += "current LUT: " + LUT + "\n";
        debugText += gCameraMgr.GetDebugText();
        debugText += gInput.GetDebugText();
        debugText += seperator;
        Player@ player = GetPlayer();
        if (player !is null)
            debugText += player.GetDebugText();
        debugText += seperator;

        Text@ text = ui.root.GetChild("debug", true);
        if (text !is null)
            text.text = debugText;
    }
}

void DebugPostUpdate()
{
    Scene@ scene_ = script.defaultScene;
    if (scene_ is null)
        return;

    DebugRenderer@ debug = scene_.debugRenderer;
    if (drawDebug == 0)
        return;

    if (drawDebug > 0)
    {
        gCameraMgr.DebugDraw(debug);
        debug.AddNode(scene_, 1.0f, false);
        gGame.DebugDraw(debug);
    }
    if (drawDebug > 1)
        scene_.physicsWorld.DrawDebugGeometry(true);
}

void DebugKey(int key)
{
    Scene@ scene_ = script.defaultScene;
    if (key == KEY_F1)
    {
        ++drawDebug;
        if (drawDebug > 3)
            drawDebug = 0;

        Text@ text = ui.root.GetChild("debug", true);
        if (text !is null)
            text.visible = drawDebug != 0;

        SaveGlobalVars();
    }
    else if (key == KEY_F2)
        debugHud.ToggleAll();
    else if (key == KEY_F3)
        console.Toggle();
    else if (key == KEY_F4)
    {
        Camera@ cam = gCameraMgr.GetCamera();
        if (cam !is null)
            cam.fillMode = (cam.fillMode == FILL_SOLID) ? FILL_WIREFRAME : FILL_SOLID;
    }
    else if (key == KEY_F5)
        ToggleDebugWindow();
    else if (key == KEY_1)
        ShootSphere(scene_);
    else if (key == KEY_2)
        ShootBox(scene_);
    else if (key == KEY_3)
    {
        debugCamera = !debugCamera;
        gCameraMgr.SetDebugCamera(debugCamera);
        ui.cursor.visible = !debugCamera;
        SaveGlobalVars();
    }
    else if (key == KEY_4)
    {
        colorGradingIndex ++;
        SetColorGrading(colorGradingIndex);
        SaveGlobalVars();
    }
    else if (key == KEY_5)
    {
        colorGradingIndex --;
        SetColorGrading(colorGradingIndex);
        SaveGlobalVars();
    }
    else if (key == 'R' || key == 'r')
        scene_.updateEnabled = !scene_.updateEnabled;
    else if (key == 'T'  || key == 't')
    {
        scene_.timeScale = (scene_.timeScale >= 0.999f) ? 0.1f : 1.0f;
    }
    else if (key == 'Q' || key == 'q')
        engine.Exit();
    else if (key == 'E' || key == 'e')
    {
        String testName = GetAnimationName("AS_INTERACT_Interact/A_Max_GP_Interact_Door01_SF");
        Array<String> testAnimations;
        Player@ player = GetPlayer();
        testAnimations.Push(testName);
        //testAnimations.Push("BM_Climb/Dangle_Right");
        testAnimations.Push(GetAnimationName("AS_INTERACT_Interact/A_Max_GP_Interact_Door02_SF"));
        if (player !is null)
            player.TestAnimation(testAnimations);
    }
    else if (key == 'F' || key == 'f')
    {
        scene_.timeScale = 1.0f;
        // SetWorldTimeScale(scene_, 1);
    }
    else if (key == 'I' || key == 'i')
    {
        Player@ p = GetPlayer();
        if (p !is null)
            p.SetPhysicsType(1 - p.physicsType);
    }
    else if (key == 'M' || key == 'm')
    {
        Player@ p = GetPlayer();
        if (p !is null)
        {
            Print("------------------------------------------------------------");
            for (uint i=0; i<p.stateMachine.states.length; ++i)
            {
                State@ s = p.stateMachine.states[i];
                Print("name=" + s.name + " nameHash=" + s.nameHash.ToString());
            }
            Print("------------------------------------------------------------");
        }
    }
    else if (key == 'U' || key == 'u')
    {
        Player@ p = GetPlayer();
        if (p.timeScale > 1.0f)
            p.timeScale = 1.0f;
        else
            p.timeScale = 1.25f;
    }
    else if (key == 'G' || key == 'g')
    {
        GetPlayer().ChangeState("OpenDoorState");
    }
}

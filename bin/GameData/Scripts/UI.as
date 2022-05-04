// ==============================================
//
//    All UI related functions
//
// ==============================================
const String UI_FONT = "Fonts/GAEN.ttf";
int UI_FONT_SIZE = 20;
const String TAG_LOADING ="TAG_LOADING";

class TextMenu
{
    UIElement@          root;
    Array<String>       texts;
    Array<Text@>        items;
    String              fontName;
    int                 fontSize;
    int                 selection = 0;
    Color               highLightColor = Color(1, 1, 0);
    Color               normalColor = Color(1, 0, 0);
    IntVector2          size = IntVector2(400, 100);
    uint                lastDirectionKeyTime = 0;

    TextMenu(const String& fName, int fSize)
    {
        fontName = fName;
        fontSize = fSize;
    }

    void Add()
    {
        if (root !is null)
            return;

        root = ui.root.CreateChild("UIElement");
        if (!engine.headless)
        {
            int height = graphics.height / 22;
            if (height > 64)
                height = 64;

            root.SetAlignment(HA_CENTER, VA_CENTER);
            root.SetPosition(0, -height * 2);
        }

        root.SetLayout(LM_VERTICAL, 8);
        root.SetFixedSize(size.x, size.y);

        for (uint i=0; i<texts.length; ++i)
        {
            AddText(texts[i]);
        }

        items[selection].color = highLightColor;
        lastDirectionKeyTime = time.systemTime;
    }

    void Remove()
    {
        if (root is null)
            return;
        items.Clear();
        root.Remove();
        root = null;
    }

    void AddText(const String& str)
    {
        Text@ text = root.CreateChild("Text");
        text.SetFont(cache.GetResource("Font", fontName), fontSize);
        text.text = str;
        text.color = normalColor;
        items.Push(text);
    }

    int Update(float dt)
    {
        int selIndex = selection;
        int inputDirection = gInput.GetDirectionPressed();
        if (inputDirection >= 0)
        {
            uint time_diff = time.systemTime - lastDirectionKeyTime;
            if (time_diff < 200)
                inputDirection = -1;
            else
                lastDirectionKeyTime = time.systemTime;
        }

        if (inputDirection == 0)
            selIndex --;
        if (inputDirection == 1)
            selIndex ++;
        if (inputDirection == 2)
            selIndex ++;
        if (inputDirection == 3)
            selIndex --;

        if (selIndex >= int(items.length))
            selIndex = 0;
        if (selIndex < 0)
            selIndex = int(items.length) - 1;

        ChangeSelection(selIndex);
        return gInput.IsEnterPressed() ? selection : -1;
    }

    void ChangeSelection(int index)
    {
        if (selection == index)
            return;

        if (selection >= 0)
            items[selection].color = normalColor;

        selection = index;
        if (selection >= 0)
            items[selection].color = highLightColor;
    }
};


void SetWindowTitleAndIcon()
{
    Image@ icon = cache.GetResource("Image", "Textures/UrhoIcon.png");
    graphics.windowIcon = icon;
}

void CreateConsoleAndDebugHud()
{
    // Get default style
    XMLFile@ xmlFile = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    if (xmlFile is null)
        return;

    // Create consoleui
    Console@ console = engine.CreateConsole();
    console.defaultStyle = xmlFile;
    console.background.opacity = 0.8f;

    // Create debug HUD
    DebugHud@ debugHud = engine.CreateDebugHud();
    debugHud.defaultStyle = xmlFile;
}

void CreateUI()
{
    ui.root.defaultStyle = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    // Create a Cursor UI element because we want to be able to hide and show it at will. When hidden, the mouse cursor will
    // control the camera, and when visible, it will point the raycast target
    XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    Cursor@ cursor = Cursor();
    cursor.SetStyleAuto(style);
    ui.cursor = cursor;
    cursor.visible = false;

    // Set starting position of the cursor at the rendering window center
    //cursor.SetPosition(graphics.width / 2, graphics.height / 2);
    //input.SetMouseVisible(true);
    Text@ text = ui.root.CreateChild("Text", "debug");
    text.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 12);
    text.horizontalAlignment = HA_LEFT;
    text.verticalAlignment = VA_TOP;
    text.SetPosition(5, 0);
    text.color = Color(0, 0, 1);
    text.priority = -99999;
    // text.textEffect = TE_SHADOW;
}

void CreateLoadingUI()
{
    float alphaDuration = 1.0f;
    ValueAnimation@ alphaAnimation = ValueAnimation();
    alphaAnimation.SetKeyFrame(0.0f, Variant(0.0f));
    alphaAnimation.SetKeyFrame(alphaDuration, Variant(1.0f));
    alphaAnimation.SetKeyFrame(alphaDuration * 2, Variant(0.0f));

    Texture2D@ logoTexture = cache.GetResource("Texture2D", "Textures/ulogo.jpg");
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

    Texture2D@ loadingTexture = cache.GetResource("Texture2D", "Textures/Loading.tga");
    Sprite@ loadingSprite = ui.root.CreateChild("Sprite", "loading_bg");
    loadingSprite.texture = loadingTexture;
    textureWidth = loadingTexture.width;
    textureHeight = loadingTexture.height;
    loadingSprite.SetSize(textureWidth, textureHeight);
    loadingSprite.SetPosition(graphics.width/2 - textureWidth/2, graphics.height/2 - textureHeight/2);
    loadingSprite.priority = -100;
    loadingSprite.opacity = 0.0f;
    loadingSprite.AddTag(TAG_LOADING);
    loadingSprite.SetAttributeAnimation("Opacity", alphaAnimation);
}


void DestroyLoadingUI()
{
    Array<UIElement@>@ elements = ui.root.GetChildrenWithTag(TAG_LOADING);
    for (uint i = 0; i < elements.length; ++i)
        elements[i].Remove();
}


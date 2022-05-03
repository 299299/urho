// Urho3D Sound Type manager

Window@ soundTypeEditorWindow;
// Dictionary mappings;
Array<SoundTypeMapping@> arr_mappings;

const uint DEFAULT_SOUND_TYPES_COUNT = 1;

class SoundTypeMapping
{
    String key;
    float value;

    SoundTypeMapping()
    {
    }
    
    SoundTypeMapping(const String&in key, const float&in value)
    {
        this.key = key;
        this.value = Clamp(value, 0.0f, 1.0f);
    }
    
    void Update(float value)
    {
        this.value = Clamp(value, 0.0f, 1.0f);
        audio.masterGain[this.key] = this.value;
    }
}

bool MappingExists(const String&in key)
{
    return  MappingGet(key) !is null;
}

SoundTypeMapping@ MappingGet(const String&in key)
{
    for (uint i=0; i<arr_mappings.length; ++i)
    {
        if (arr_mappings[i].key == key)
        {
            return arr_mappings[i];
        }
    }
    return null;
}

void MappingSet(SoundTypeMapping@ mapping)
{
    arr_mappings.Push(mapping);
}

void MappingErase(const String& key)
{
    uint index = -1;
    for (uint i=0; i<arr_mappings.length; ++i)
    {
        if (arr_mappings[i].key == key)
        {
            index = i;
            break;
        }
    }

    if (index != -1)
    {
        arr_mappings.Erase(index);
    }
}


void CreateSoundTypeEditor()
{
    if (soundTypeEditorWindow !is null)
        return;
        
    soundTypeEditorWindow = ui.LoadLayout(cache.GetResource("XMLFile", "UI/EditorSoundTypeWindow.xml"));
    ui.root.AddChild(soundTypeEditorWindow);
    soundTypeEditorWindow.opacity = uiMaxOpacity;

    InitSoundTypeEditorWindow();
    RefreshSoundTypeEditorWindow();

    int height = Min(ui.root.height - 60, 750);    
    soundTypeEditorWindow.SetSize(400, 0);
    CenterDialog(soundTypeEditorWindow);

    HideSoundTypeEditor();
    
    SubscribeToEvent(soundTypeEditorWindow.GetChild("CloseButton", true), "Released", "HideSoundTypeEditor");
    SubscribeToEvent(soundTypeEditorWindow.GetChild("AddButton", true), "Released", "AddSoundTypeMapping");
    
    SubscribeToEvent(soundTypeEditorWindow.GetChild("MasterValue", true), "TextFinished", "EditGain");
}

void InitSoundTypeEditorWindow()
{
    if (!MappingExists(SOUND_MASTER))
        MappingSet(SoundTypeMapping(SOUND_MASTER, audio.masterGain[SOUND_MASTER]));
        
    for (uint i = DEFAULT_SOUND_TYPES_COUNT; i < arr_mappings.length; i++)
    {
        SoundTypeMapping@ mapping = arr_mappings[i];
        AddUserUIElements(mapping.key, mapping.value);
    }    
}

void RefreshSoundTypeEditorWindow()
{
    RefreshDefaults(soundTypeEditorWindow.GetChild("DefaultsContainer"));
    RefreshUser(soundTypeEditorWindow.GetChild("UserContainer"));
}

void RefreshDefaults(UIElement@ root)
{
    UpdateMappingValue(SOUND_MASTER, root.GetChild(SOUND_MASTER, true));
}

void RefreshUser(UIElement@ root)
{
    for (uint i = DEFAULT_SOUND_TYPES_COUNT; i < arr_mappings.length; i++)
    {
        SoundTypeMapping@ mapping = arr_mappings[i];
        UpdateMappingValue2(mapping, root.GetChild(mapping.key, true));
    }
}

void UpdateMappingValue2(SoundTypeMapping@ mapping, UIElement@ root)
{
    if (mapping !is null and root !is null)
    {
        LineEdit@ value = root.GetChild(mapping.key + "Value");
        if (mapping !is null && value !is null)
        {
            value.text = mapping.value;
            root.vars["DragDropContent"] = mapping.key;
        }
    }
}

void UpdateMappingValue(const String&in key, UIElement@ root)
{
    if (root !is null)
    {
        LineEdit@ value = root.GetChild(key + "Value");
        SoundTypeMapping@ mapping = MappingGet(key);
        
        if (mapping !is null && value !is null)
        {
            value.text = mapping.value;
            root.vars["DragDropContent"] = mapping.key;
        }
    }
}

void AddUserUIElements(const String&in key, const String&in gain)
{
    ListView@ container = soundTypeEditorWindow.GetChild("UserContainer", true);

    UIElement@ itemParent = UIElement();
    container.AddItem(itemParent);

    itemParent.style = "ListRow";
    itemParent.name = key;
    itemParent.layoutSpacing = 10;

    Text@ keyText = Text();
    LineEdit@ gainEdit = LineEdit();
    Button@ removeButton = Button();

    itemParent.AddChild(keyText);
    itemParent.AddChild(gainEdit);
    itemParent.AddChild(removeButton);
    itemParent.dragDropMode = DD_SOURCE;

    keyText.text = key;
    keyText.textAlignment = HA_LEFT;
    keyText.SetStyleAuto();

    gainEdit.maxLength = 4;
    gainEdit.maxWidth = 2147483647;
    gainEdit.minWidth = 100;
    gainEdit.name = key + "Value";
    gainEdit.text = gain;
    gainEdit.SetStyleAuto();

    removeButton.style = "CloseButton";

    SubscribeToEvent(removeButton, "Released", "DeleteSoundTypeMapping");
    SubscribeToEvent(gainEdit, "TextFinished", "EditGain");
}

void AddSoundTypeMapping(StringHash eventType, VariantMap& eventData)
{
    UIElement@ button = eventData["Element"].GetPtr();
    LineEdit@ key = button.parent.GetChild("Key");
    LineEdit@ gain = button.parent.GetChild("Gain");
    
    if (!key.text.empty && !gain.text.empty && !MappingExists(key.text))
    {
        SoundTypeMapping@ mapping = SoundTypeMapping(key.text, gain.text.ToFloat());
        MappingSet(mapping);
        AddUserUIElements(key.text, mapping.value);
    }
    
    key.text = "";
    gain.text = "";
    
    RefreshSoundTypeEditorWindow();
}

void DeleteSoundTypeMapping(StringHash eventType, VariantMap& eventData)
{
    UIElement@ button = eventData["Element"].GetPtr();
    UIElement@ parent = button.parent;
    
    MappingErase(parent.name);
    parent.Remove();
}

void EditGain(StringHash eventType, VariantMap& eventData)
{
    LineEdit@ input = eventData["Element"].GetPtr();
    String key = input.parent.name;
    
    SoundTypeMapping@ mapping = MappingGet(key);
    if (mapping !is null)
        mapping.Update(input.text.ToFloat());
        
    RefreshSoundTypeEditorWindow();
}

bool ToggleSoundTypeEditor()
{
    if (soundTypeEditorWindow.visible == false)
        ShowSoundTypeEditor();
    else
        HideSoundTypeEditor();
    return true;
}

void ShowSoundTypeEditor()
{
    RefreshSoundTypeEditorWindow();
    soundTypeEditorWindow.visible = true;
    soundTypeEditorWindow.BringToFront();
}

void HideSoundTypeEditor()
{
    soundTypeEditorWindow.visible = false;
}

void SaveSoundTypes(XMLElement&in root)
{
    for (uint i = 0; i < arr_mappings.length; i++)
    {
        SoundTypeMapping@ mapping = arr_mappings[i];
        root.SetFloat(mapping.key, mapping.value);
    }
}

void LoadSoundTypes(const XMLElement&in root)
{
    for (uint i = 0; i < root.numAttributes ; i++)
    {
        String key = root.GetAttributeNames()[i];
        float gain = root.GetFloat(key);
    
        if (!key.empty && !MappingExists(key))
            MappingSet(SoundTypeMapping(key, gain));
    }
}
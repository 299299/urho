

class Gif
{
    String name;
    Array<Texture2D@> textures;
    Sprite@ sprite;
    int index = 0;
    int size = 96;
    bool looped = false;
    float duration = 1.0;
    float time = 0.0;
    int length = 0;
    bool finished = false;

    Gif(const String&in name_, int num_, int size_, float duration_, bool loop_)
    {
        name = name_;
        length = num_;
        for (int i=1; i<=length; ++i)
        {
            textures.Push(cache.GetResource("Texture2D", "Textures/" + name + "_" + i + ".tga"));
        }
        size = size_;
        duration = duration_;
        looped = loop_;
    }

    void Start()
    {
        index = 0;
        time = 0.0;
        sprite = ui.root.CreateChild("Sprite", "Gif_" + name);
        sprite.blendMode = BLEND_REPLACE;
        sprite.visible = true;
        sprite.texture = textures[index];
        // sprite.size = IntVector2(size, size);
        // sprite.hotSpot = IntVector2(size/2, size/2);

        int textureWidth = sprite.texture.width;
        int textureHeight = sprite.texture.height;
        sprite.SetScale(size / textureWidth);
        sprite.SetSize(textureWidth, textureHeight);
        sprite.SetHotSpot(textureWidth/2, textureHeight/2);
        sprite.SetPosition(graphics.width/2 - textureWidth/2, graphics.height/2 - textureHeight/2);
    }

    void Stop()
    {
        sprite.Remove();
    }

    void Update(float dt)
    {
        time += dt;

        bool update_tex = false;

        if (time > duration) {
            time = 0;
            index ++;
            update_tex = true;
        }

        // end gif
        if (index >= textures.length)
        {
            if (looped)
            {
                index = 0;
            }
            else
            {
                index -= 1;
            }
            finished = true;
        }

        if (update_tex) {
            sprite.texture = textures[index];
        }
    }
}

using Raylib_cs;
using static Raylib_cs.Raylib;

namespace SoulGrid.Shared;

public partial class Assets
{
    public Dictionary<string, Texture2D> Textures = new Dictionary<string, Texture2D>();

    private Assets() { }
    private static Assets? _instance;
    private Random _random = new Random();
    
    public static Color UnpackColor(uint hex)
    {
        byte r = (byte)((hex >> 24) & 0xFF);
        byte g = (byte)((hex >> 16) & 0xFF);
        byte b = (byte)((hex >> 8) & 0xFF);
        byte a = (byte)(hex & 0xFF);

        return new Color(r, g, b, a);
    }
    
    public static Assets Get()
    {
        if (_instance == null)
            _instance = new Assets();
        return _instance;
    }

    public Texture2D RandomTexture(string name)
    {
        var textures = new List<Texture2D>();

        foreach (var (key, value) in Textures)
        {
            if (key.Contains(name)) textures.Add(value);
        }

        return textures[_random.Next(textures.Count())];
    }

    public void Load()
    {
        // Walls
        for (int i = 1; i <= 7; i++)
            Textures[$"wall_{i}"] = LoadTexture($"Assets/walls/wall_{i}.png");
        // Floors
        for (int i = 1; i <= 6; i++)
            Textures[$"floor_{i}"] = LoadTexture($"Assets/floors/floor_{i}.png");
        // Doors
        for (int i = 1; i <= 7; i++)
            Textures[$"door_open_{i}"] = LoadTexture($"Assets/doors_open/door_open_{i}.png");
        for (int i = 1; i <= 6; i++)
            Textures[$"door_closed_{i}"] = LoadTexture($"Assets/doors_closed/door_closed_{i}.png");
        // Player
        Textures["demon"] = LoadTexture("Assets/monsters/demon.png");
        // Effects
        for (int i = 1; i <= 3; i++)
            Textures[$"attack_slash_{i}"] = LoadTexture($"Assets/attack_effects/slash_{i}.png");
        for (int i = 1; i <= 3; i++)
            Textures[$"attack_splash_{i}"] = LoadTexture($"Assets/attack_effects/splash_{i}.png");
        Textures["attack_stun"] = LoadTexture("Assets/attack_effects/stun.png");
        // Items
        // Enemies
        for (int i = 1; i <= 7; i++)
            Textures[$"cultist_{i}"] = LoadTexture($"Assets/cultists/cultist_{i}.png");
        // HUD
        Textures["unknown"] = LoadTexture("Assets/hud/unknown.png");

        foreach (var (key, texture) in Textures)
        {
            SetTextureFilter(texture, TextureFilter.Point);
        }
    }

    public void Unload()
    {
        foreach (var (key, texture) in Textures)
        {
            UnloadTexture(texture);
        }
    }
}
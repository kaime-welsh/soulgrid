using System.Numerics;
using Raylib_cs;
using static Raylib_cs.Raylib;

namespace SoulGrid;

public class Assets
{
    public Dictionary<string, Texture2D> Textures = new Dictionary<string, Texture2D>();

    private Assets() { }
    private static Assets? _instance;
    private Random _random = new Random();

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
            Textures[$"wall_{i}"] = LoadTexture($"assets/walls/wall_{i}.png");
        // Floors
        for (int i = 1; i <= 6; i++)
            Textures[$"floor_{i}"] = LoadTexture($"assets/floors/floor_{i}.png");
        // Doors
        for (int i = 1; i <= 7; i++)
            Textures[$"door_open_{i}"] = LoadTexture($"assets/doors_open/door_open_{i}.png");
        for (int i = 1; i <= 6; i++)
            Textures[$"door_closed_{i}"] = LoadTexture($"assets/doors_closed/door_closed_{i}.png");
        // Player
        Textures["demon"] = LoadTexture("assets/monsters/demon.png");
        // Effects
        for (int i = 1; i <= 3; i++)
            Textures[$"attack_slash_{i}"] = LoadTexture($"assets/attack_effects/slash_{i}.png");
        for (int i = 1; i <= 3; i++)
            Textures[$"attack_splash_{i}"] = LoadTexture($"assets/attack_effects/splash_{i}.png");
        Textures["attack_stun"] = LoadTexture("assets/attack_effects/stun.png");
        // Items
        // Enemies
        for (int i = 1; i <= 7; i++)
            Textures[$"cultist_{i}"] = LoadTexture($"assets/cultists/cultist_{i}.png");
        // HUD
        Textures["unknown"] = LoadTexture("assets/hud/unknown.png");

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

public class Program
{
    [System.STAThread]
    public static void Main()
    {
        SetConfigFlags(ConfigFlags.ResizableWindow);
        InitWindow(1280, 720, "SOUL GRID");
        SetTargetFPS(60);

        RenderTexture2D target = LoadRenderTexture(GameSettings.ScreenWidth, GameSettings.ScreenHeight);

        Assets.Get().Load();

        Scene.Push(new GameScene());

        while (!WindowShouldClose())
        {
            float scale = MathF.Min(
                (float)GetScreenWidth() / GameSettings.ScreenWidth,
                (float)GetScreenHeight() / GameSettings.ScreenHeight
            );

            SetMouseOffset((int)(-(GetScreenWidth() - (GameSettings.ScreenWidth * scale)) * 0.5f), (int)(-(GetScreenHeight() - (GameSettings.ScreenHeight * scale)) * 0.5f));
            SetMouseScale(1 / scale, 1 / scale);

            Scene.Current().Update(GetFrameTime());

            BeginTextureMode(target);
            Scene.Current().Draw();
            EndTextureMode();

            BeginDrawing();
            ClearBackground(Color.Black);
            Rectangle sourceRec = new(
                            0.0f,
                            0.0f,
                            (float)target.Texture.Width,
                            (float)-target.Texture.Height
                        );
            Rectangle destRec = new(
                (GetScreenWidth() - ((float)GameSettings.ScreenWidth * scale)) * 0.5f,
                (GetScreenHeight() - ((float)GameSettings.ScreenHeight * scale)) * 0.5f,
                (float)GameSettings.ScreenWidth * scale,
                (float)GameSettings.ScreenHeight * scale
            );
            DrawTexturePro(target.Texture, sourceRec, destRec, new Vector2(0, 0), 0.0f, Color.White);
            EndDrawing();
        }

        Assets.Get().Unload();
        Scene.UnloadAll();
        CloseWindow();
    }
}

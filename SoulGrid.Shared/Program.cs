using System.Numerics;
using Raylib_cs;
using static Raylib_cs.Raylib;
using SoulGrid.Core;

namespace SoulGrid.Shared;

public class Program
{
    private static RenderTexture2D target;
    private static float scale => MathF.Min(
        (float)GetScreenWidth() / GameSettings.ScreenWidth,
        (float)GetScreenHeight() / GameSettings.ScreenHeight
    );

    public static void Init(int width, int height)
    {
        SetConfigFlags(ConfigFlags.ResizableWindow);
        InitWindow(width, height, "SOUL GRID");
        SetTargetFPS(60);

        target = LoadRenderTexture(GameSettings.ScreenWidth, GameSettings.ScreenHeight);

        Assets.Get().Load();

        Scene.Push(new GameScene());
    }

    public static void Update()
    {

        SetMouseOffset((int)(-(GetScreenWidth() - (GameSettings.ScreenWidth * scale)) * 0.5f),
            (int)(-(GetScreenHeight() - (GameSettings.ScreenHeight * scale)) * 0.5f));
        SetMouseScale(1 / scale, 1 / scale);

        Scene.Current().Update(GetFrameTime());

        BeginTextureMode(target);
        Scene.Current().Draw();
        EndTextureMode();
    }

    public static void Draw()
    {
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

    public static void Unload()
    {
        Assets.Get().Unload();
        Scene.UnloadAll();
        CloseWindow();
    }
}
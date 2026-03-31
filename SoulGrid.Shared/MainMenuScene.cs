using System.Numerics;
using Raylib_cs;
using static Raylib_cs.Raylib;
using SoulGrid.Core;

namespace SoulGrid.Shared;

public static class Gui
{
    private static bool wasPressed = false;

    public static bool Button(Vector2 pos, string msg, bool centered = false, float fontSize = 10.0f, float fontSpacing = 1.0f)
    {
        var isHovered = false;
        var isClicked = false;
        var color = Color.White;
        var textSize = MeasureTextEx(GetFontDefault(), msg, fontSize, fontSpacing);

        var posOffset = new Vector2(-(textSize.X / 2), -(textSize.Y / 2));
        if (centered)
        {
            pos += posOffset;
        }
        var rect = new Rectangle(pos.X, pos.Y, textSize.X + 8, textSize.Y + 8);

        if (CheckCollisionPointRec(GetMousePosition(), rect))
        {
            isHovered = true;
            if (IsMouseButtonDown(MouseButton.Left))
            {
                wasPressed = true;
            }
        }
        if (wasPressed && IsMouseButtonReleased(MouseButton.Left)) return true;

        if (isHovered && isClicked) color = Color.Green;
        else if (isHovered) color = Color.Yellow;

        DrawRectangleLinesEx(rect, 2.0f, color);
        DrawTextEx(GetFontDefault(), msg, pos + new Vector2(4, 4), fontSize, fontSpacing, color);

        return false;
    }

}

public class MainMenuScene : Scene
{
    public override void OnEnter()
    {
    }

    public override void Draw()
    {
        ClearBackground(Color.Black);
        var font = GetFontDefault();
        var titleSize = MeasureTextEx(GetFontDefault(), "SOUL::GRID", 48.0f, 2.0f);
        DrawTextEx(font, "SOUL::GRID", new Vector2((GameSettings.ScreenWidth / 2) - (titleSize.X / 2), (GameSettings.ScreenHeight / 4) - (titleSize.Y / 2)), 48.0f, 2.0f, Color.White);

        if (Gui.Button(new Vector2(GameSettings.ScreenWidth / 2, GameSettings.ScreenHeight / 2), "Start Run", true))
        {
            Scene.Push(new GameScene());
        }
    }

    public override void Unload()
    {
    }

    public override void Update(float dt)
    {
    }
}

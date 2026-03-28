using Raylib_cs;
using static Raylib_cs.Raylib;

namespace SoulGrid.Shared;

public class Input
{
    public static readonly KeyboardKey[] Up = [KeyboardKey.W, KeyboardKey.K, KeyboardKey.Up];
    public static readonly KeyboardKey[] Down = [KeyboardKey.S, KeyboardKey.J, KeyboardKey.Down];
    public static readonly KeyboardKey[] Left = [KeyboardKey.A, KeyboardKey.H, KeyboardKey.Left];
    public static readonly KeyboardKey[] Right = [KeyboardKey.D, KeyboardKey.L, KeyboardKey.Right];
    public static readonly KeyboardKey[] Confirm = [KeyboardKey.R, KeyboardKey.Enter];
    public static readonly KeyboardKey[] Cancel = [KeyboardKey.Escape, KeyboardKey.Backspace];

    public static bool Pressed(Span<KeyboardKey> keys, bool repeat = true)
    {
        foreach (KeyboardKey key in keys)
        {
            if (IsKeyPressed(key) || (repeat && IsKeyPressedRepeat(key)))
                return true;
        }
        return false;
    }
}


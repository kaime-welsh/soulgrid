namespace SoulGrid.Core;

public static class GameSettings
{
    public static readonly int ScreenWidth = 640 / 2;
    public static readonly int ScreenHeight = 480 / 2;
    public static readonly int CellSize = 32 / 2;
}

public static class Palette
{
    public const uint White = 0xEBFBCCFF;
    public const uint Black = 0x151515FF;

    public const uint Wall = 0x336655FF;
    public const uint Floor = 0x221144FF;
    public const uint Exit = 0xDDFF33FF;

    public const uint Player = 0x33EE66FF;
    public const uint Cultist = 0xEE2277FF;
}

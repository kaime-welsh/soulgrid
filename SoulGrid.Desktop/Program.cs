using System.Numerics;
using Raylib_cs;
using static Raylib_cs.Raylib;

namespace SoulGrid.Desktop;

public class Program
{
    [System.STAThread]
    public static void Main()
    {
        Shared.App.Init(1280, 720);
        MaximizeWindow();

        while (!WindowShouldClose())
        {
            Shared.App.Update();
            Shared.App.Draw();
        }

        Shared.App.Unload();
    }
}

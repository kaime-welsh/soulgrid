using System.Numerics;
using Raylib_cs;
using static Raylib_cs.Raylib;

namespace SoulGrid.Desktop;

public class Program
{
    [System.STAThread]
    public static void Main()
    {
        Shared.Program.Init(1280, 720);
        MaximizeWindow();

        while (!WindowShouldClose())
        {
            Shared.Program.Update();
            Shared.Program.Draw();
        }

        Shared.Program.Unload();
    }
}

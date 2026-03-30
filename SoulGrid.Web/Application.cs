using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Runtime.InteropServices.JavaScript;
using Raylib_cs;
using static Raylib_cs.Raylib;

using SoulGrid.Core;

namespace SoulGrid.Web;

public partial class Application
{
    public static void Main()
    {
        Shared.Program.Init(600, 400);
    }

    [JSExport]
    public static void UpdateFrame()
    {
        if (IsMouseButtonDown(MouseButton.Left))
        Shared.Program.Update();
        Shared.Program.Draw();
    }
}

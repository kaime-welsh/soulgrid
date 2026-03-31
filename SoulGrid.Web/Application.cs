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
        Shared.App.Init(600, 400);
    }

    [JSExport]
    public static void UpdateFrame()
    {
        Shared.App.Update();
        Shared.App.Draw();
    }
}

using SoulGrid.Core;

namespace SoulGrid.Entities;

public class Cultist : Entity
{
    public Cultist(int x, int y) : base(EntityType.Cultist, x, y, 1) { }

    public override Intent? Think()
    {
        Entity player = World.Get().Player;
        TileMap map = World.Get().Map;
        Random rng = World.Get().Random;

        int diffX = player.X - this.X;
        int diffY = player.Y - this.Y;

        int idealX = Math.Sign(diffX);
        int idealY = Math.Sign(diffY);

        var primaryDirs = new List<(int x, int y)>();
        if (idealX != 0) primaryDirs.Add((idealX, 0));
        if (idealY != 0) primaryDirs.Add((0, idealY));

        if (primaryDirs.Count == 2 && rng.Next(2) == 0)
        {
            (primaryDirs[0], primaryDirs[1]) = (primaryDirs[1], primaryDirs[0]);
        }

        var allCardinals = new List<(int x, int y)> { (0, 1), (0, -1), (1, 0), (-1, 0) };
        var fallbacks = allCardinals
            .Where(d => !primaryDirs.Contains(d))
            .OrderBy(_ => rng.Next()) // Randomize the fallback order
            .ToList();

        var testDirs = primaryDirs.Concat(fallbacks).ToList();

        foreach (var dir in testDirs)
        {
            // Just in case (0,0) sneaks in
            if (dir.x == 0 && dir.y == 0) continue;

            int checkX = this.X + dir.x;
            int checkY = this.Y + dir.y;

            if (map.GetAt(checkX, checkY) == TileType.Wall) continue;

            Entity? occupant = World.Get().GetEntityAt(checkX, checkY);
            if (occupant != null && occupant != player) continue;

            return new MoveIntent(dir.x, dir.y);
        }

        return null;
    }
}

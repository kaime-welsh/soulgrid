using System.Numerics;
namespace SoulGrid.Core;

public enum TileType { Wall, Floor, Exit }

public struct TileMap
{
    public int Width;
    public int Height;
    public List<Vector2> OpenTiles;

    private TileType[] tiles;

    public TileMap(int width, int height)
    {
        Width = width;
        Height = height;
        tiles = new TileType[width * height];
        OpenTiles = new List<Vector2>();
    }

    public void Reset()
    {
        Array.Fill(tiles, TileType.Wall);
        OpenTiles.Clear();
    }

    public bool InBounds(int x, int y) => x >= 0 && x < Width && y >= 0 && y < Height;
    public TileType GetAt(int x, int y) => InBounds(x, y) ? tiles[y * Width + x] : TileType.Wall;
    public void SetAt(int x, int y, TileType type) { if (InBounds(x, y)) tiles[y * Width + x] = type; }

    public void GenerateFloor(Random random)
    {
        Reset();
        Vector2 walkerPos = new Vector2(Width / 2, Height / 2);

        int targetFloorCount = (int)((Width - 2) * (Height - 2) * 0.50);

        Vector2[] directions = new Vector2[]
        {
            new Vector2(0, -1), // Up
            new Vector2(0, 1),  // Down
            new Vector2(-1, 0), // Left
            new Vector2(1, 0)   // Right
        };

        Vector2 currentDir = directions[random.Next(directions.Length)];

        double chanceToTurn = 0.20;
        double chanceToCreateRoom = 0.05;

        int maxLifespan = 80;
        int currentLifespan = 0;

        while (OpenTiles.Count < targetFloorCount)
        {
            if (currentLifespan >= maxLifespan && OpenTiles.Count > 0)
            {
                int randomIndex = random.Next(OpenTiles.Count);
                walkerPos = OpenTiles.ElementAt(randomIndex);

                currentDir = directions[random.Next(directions.Length)];
                currentLifespan = 0;
            }

            if (random.NextDouble() < chanceToCreateRoom)
            {
                int roomRadius = random.Next(1, 3);
                for (int rx = -roomRadius; rx <= roomRadius; rx++)
                {
                    for (int ry = -roomRadius; ry <= roomRadius; ry++)
                    {
                        int stampX = (int)walkerPos.X + rx;
                        int stampY = (int)walkerPos.Y + ry;

                        if (stampX > 0 && stampX < Width - 1 && stampY > 0 && stampY < Height - 1)
                        {
                            if (GetAt(stampX, stampY) != TileType.Floor)
                            {
                                SetAt(stampX, stampY, TileType.Floor);
                                OpenTiles.Add(new Vector2(stampX, stampY));
                            }
                        }
                    }
                }
            }
            else
            {
                if (GetAt((int)walkerPos.X, (int)walkerPos.Y) != TileType.Floor)
                {
                    SetAt((int)walkerPos.X, (int)walkerPos.Y, TileType.Floor);
                    OpenTiles.Add(walkerPos);
                }
            }

            if (random.NextDouble() < chanceToTurn)
            {
                currentDir = directions[random.Next(directions.Length)];
            }

            int nextX = (int)walkerPos.X + (int)currentDir.X;
            int nextY = (int)walkerPos.Y + (int)currentDir.Y;

            if (nextX > 0 && nextX < Width - 1 && nextY > 0 && nextY < Height - 1)
            {
                walkerPos.X = nextX;
                walkerPos.Y = nextY;
            }
            else
            {
                currentDir = directions[random.Next(directions.Length)];
            }

            currentLifespan++;
        }

        // Place exit
        HashSet<Vector2> potentialExits = new HashSet<Vector2>();
        foreach (Vector2 floorPos in OpenTiles)
        {
            foreach (Vector2 dir in directions)
            {
                int checkX = (int)(floorPos.X + dir.X);
                int checkY = (int)(floorPos.Y + dir.Y);

                if (GetAt(checkX, checkY) == TileType.Wall)
                {
                    potentialExits.Add(new Vector2(checkX, checkY));
                }
            }
        }

        if (potentialExits.Count > 0)
        {
            int exitIndex = random.Next(potentialExits.Count);
            Vector2 finalExit = potentialExits.ElementAt(exitIndex);
            SetAt((int)finalExit.X, (int)finalExit.Y, TileType.Exit);
        }
    }
}

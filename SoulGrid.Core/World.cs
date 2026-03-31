using System.Numerics;
using SoulGrid.Core.Entities;
namespace SoulGrid.Core;

public sealed class World
{
    public TileMap Map { get; }
    public List<Entity> Entities;
    public Player Player { get; private set; }

    public int CurrentFloor { get; private set; } = 0;
    public bool JustChangedFloor { get; set; } = false;

    public Random Random { get; } = new Random();

    public event Action? OnReset;

    private static World? _instance;

    private World(int width = 11, int height = 11)
    {
        Map = new TileMap(width, height);
        Entities = new List<Entity>();
        Player = new Player(1, 1);
        AddEntity(Player);
    }
    
    public static World Get() => _instance ??= new World();

    public Entity? GetEntityAt(int x, int y)
    {
        return Entities.FirstOrDefault(e => e.X == x && e.Y == y && e.IsAlive);
    }

    private Entity AddEntity(Entity entity)
    {
        Entities.Add(entity);
        return entity;
    }
    
    public void Restart()
    {
        CurrentFloor = 1;
        Entities.Clear();

        Player = new Player(1, 1);
        AddEntity(Player);

        Generate();

        TurnManager.Get().TurnCount = 0;
        TurnManager.Get().Reset();
        TurnManager.Get().GatherEntityIntents();
        OnReset?.Invoke();
    }
    
    public void NextFloor()
    {
        CurrentFloor++;
        Entities.Clear();
        Entities.Add(Player);
        Generate();
        JustChangedFloor = true;
        TurnManager.Get().Reset();
        TurnManager.Get().GatherEntityIntents();
        OnReset?.Invoke();
    }
    
    public void Generate()
    {
        Random random = Random;
        Map.GenerateFloor(random);

        List<Vector2> availableTiles = Map.OpenTiles.ToList();

        if (availableTiles.Count == 0) return;

        int playerIndex = random.Next(availableTiles.Count);
        Vector2 playerPos = availableTiles[playerIndex];
        availableTiles.RemoveAt(playerIndex);

        Player.X = (int)playerPos.X;
        Player.Y = (int)playerPos.Y;

        int baseMobCount = (CurrentFloor) + random.Next(1, 3);
        int mobCount = (int)(baseMobCount * TurnManager.Get().CurrentDifficulty);

        for (int i = 0; i < mobCount; i++)
        {
            if (availableTiles.Count == 0) break;

            int entIndex = random.Next(availableTiles.Count);
            Vector2 entPos = availableTiles[entIndex];
            availableTiles.RemoveAt(entIndex);

            AddEntity(new Cultist((int)entPos.X, (int)entPos.Y) { NextIntent = null });
        }
    }
}

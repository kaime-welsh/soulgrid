using System.Numerics;
using SoulGrid.Core.Entities;
namespace SoulGrid.Core;

public sealed class World
{
    public TileMap Map { get; }
    public List<Entity> Entities;
    public Player Player { get; private set; }

    public int CurrentFloor { get; private set; } = 0;
    public int TurnCount { get; private set; }
    public bool JustChangedFloor { get; set; } = false;

    public Random Random { get; } = new Random();

    public event Action? OnReset;

    private static World? _instance;

    private World()
    {
        Map = new TileMap(15, 15);
        Entities = new List<Entity>();
        Player = new Player(1, 1);
        AddEntity(Player);
    }

    public void Restart()
    {
        CurrentFloor = 1;
        TurnCount = 0;

        Entities.Clear();

        Player = new Player(1, 1);
        AddEntity(Player);

        Generate();

        OnReset?.Invoke();
    }

    public static World Get()
    {
        if (_instance == null)
            _instance = new World();
        return _instance;
    }

    public Entity? GetEntityAt(int x, int y)
    {
        return Entities.FirstOrDefault(e => e.X == x && e.Y == y && e.IsAlive);
    }

    public Entity AddEntity(Entity entity)
    {
        Entities.Add(entity);
        return entity;
    }

    public void RemoveEntity(Entity entity)
    {
        Entities.Remove(entity);
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

        int mobCount = (int)((CurrentFloor * 2) + 5);

        for (int i = 0; i < mobCount; i++)
        {
            if (availableTiles.Count == 0) break;

            int entIndex = random.Next(availableTiles.Count);
            Vector2 entPos = availableTiles[entIndex];
            availableTiles.RemoveAt(entIndex);

            AddEntity(new Cultist((int)entPos.X, (int)entPos.Y) { NextIntent = null });
        }
    }

    public void ProcessTurn()
    {

        bool playerActed = ResolveIntent(Player);
        Player.NextIntent = null;
        if (!playerActed) return;

        foreach (Entity entity in Entities)
        {
            if (entity == Player || !entity.IsAlive) continue;

            if (entity.NextIntent != null)
            {
                ResolveIntent(entity);
            }
        }

        TurnCount++;
    }

    public bool ProcessPlayerTurn()
    {
        bool acted = ResolveIntent(Player);
        Player.NextIntent = null;
        return acted;
    }

    public void GatherEntityIntent(Entity entity)
    {
        entity.NextIntent = entity.Think();
    }

    public bool ResolveIntent(Entity entity)
    {
        Intent? current = entity.NextIntent;
        bool actionSucceeded = false;

        while (current != null)
        {
            IntentResult result = current.Execute(entity);
            actionSucceeded = result.success;

            if (result.alternative != null) current = result.alternative;
            else current = null;
        }

        return actionSucceeded;
    }

    public void IncrementTurn()
    {
        TurnCount++;
        JustChangedFloor = false;
    }

    public void NextFloor()
    {
        CurrentFloor++;
        Entities.Clear();
        Entities.Add(Player);
        Generate();

        foreach (var e in Entities) e.NextIntent = null;

        JustChangedFloor = true;
        OnReset?.Invoke();
    }
}

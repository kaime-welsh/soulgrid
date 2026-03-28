namespace SoulGrid.Core;

public enum TurnState
{
    WaitingForPlayer,
    ResolvingPlayer,
    ResolvingEnemies
};

public class TurnManager
{
    private static TurnManager? _instance;
    public static TurnManager Get() => _instance ??= new TurnManager();
    
    private Queue<Entity> _turnQueue = new Queue<Entity>();
    private const float _difficultyScalingPerTurn = 0.01f;
    private const float _maxDifficultyCap = 10.0f;

    public float CurrentDifficulty => Math.Min(_maxDifficultyCap, 1.0f + (TurnCount * _difficultyScalingPerTurn));

    public int TurnCount { get; set; }
    public TurnState State { get; private set; } = TurnState.WaitingForPlayer;
    public bool IsAwaitingPlayerInput => State == TurnState.WaitingForPlayer;


    private TurnManager() { }

    public void SubmitPlayerInput(Intent intent)
    {
        if (State != TurnState.WaitingForPlayer) return;
        World.Get().Player.NextIntent = intent;
        State = TurnState.ResolvingPlayer;
    }
    
    public void Reset()
    {
        _turnQueue.Clear();
        State = TurnState.WaitingForPlayer;
    }

    public void Tick()
    {
        switch (State)
        {
            case TurnState.WaitingForPlayer:
                return; // Player hasn't gone yet
            case TurnState.ResolvingPlayer:
            {
                // Pop player intent
                bool acted = ResolveIntent(World.Get().Player);
                World.Get().Player.NextIntent = null;

                if (acted && !World.Get().JustChangedFloor) // Player went and we haven't just spawned
                {
                    // Propagate turnQueue
                    _turnQueue.Clear();
                    foreach (var entity in World.Get().Entities)
                    {
                        if (entity != World.Get().Player && entity.IsAlive)
                        {
                            _turnQueue.Enqueue(entity);
                        }
                    }

                    State = TurnState.ResolvingEnemies;
                }
                else // Action failed or we just changed floors
                {
                    World.Get().JustChangedFloor = false;
                    State = TurnState.WaitingForPlayer;
                }

                break;
            }
            case TurnState.ResolvingEnemies:
            {
                if (_turnQueue.Count() > 0)
                {
                    Entity currentEnemy = _turnQueue.Dequeue();
                    if (currentEnemy is { IsAlive: true, NextIntent: not null })
                    {
                        ResolveIntent(currentEnemy);
                        currentEnemy.NextIntent = null;
                    }
                }
                else // Queue is empty, end turn and give control back to player
                {
                    TurnCount++;
                    State = TurnState.WaitingForPlayer;
                    GatherEntityIntents();
                }
                break;
            }
        }
    }

    public void GatherEntityIntents()
    {
        foreach (var entity in World.Get().Entities)
        {
            if (entity != World.Get().Player && entity.IsAlive)
            {
                entity.NextIntent = entity.Think();
            }
        }
        
    }

    public bool ResolveIntent(Entity entity)
    {
        Intent? current = entity.NextIntent;
        bool actionSucceeded = false;
        
        // Process intent chains (intent -> alternative -> alternative -> ...)
        while (current != null)
        {
            IntentResult result = current.Execute(entity);
            actionSucceeded = result.success;

            if (result.alternative != null) current = result.alternative;
            else current = null;
        }

        return actionSucceeded;
    }
}
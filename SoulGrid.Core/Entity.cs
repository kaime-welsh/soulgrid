namespace SoulGrid.Core;

public enum EntityType { Player, Cultist, Villager, Templar }

// TODO: Allow entities to be ripped into different classes instead of fully relying on the type
public class Entity
{
    public static uint EntityCount = 0;

    public uint ID { get; }
    public EntityType Type { get; }
    public int X { get; set; }
    public int Y { get; set; }

    public int HP { get; set; }
    public bool IsAlive => HP > 0;
    // public virtual int Damage => Math.Max(1, (int)(World.Get().Player.Souls * 0.15));
    public virtual int Damage { get; set; }

    public Intent? NextIntent { get; set; }
    public Func<World, Entity, Intent?>? ThinkAction { get; set; }

    public event Action? OnCreate;
    public event Action<int, int, int, int>? OnMove;
    public event Action<Entity, int, int, int>? OnAttack;
    public event Action<int>? OnTakeDamage;
    public event Action? OnDie;

    public void TriggerCreate() => OnCreate?.Invoke();
    public void TriggerMove(int fromX, int fromY, int toX, int toY) => OnMove?.Invoke(fromX, fromY, toX, toY);
    public void TriggerAttack(Entity target, int amount, int dx, int dy) => OnAttack?.Invoke(target, amount, dx, dy);
    public void TriggerTakeDamage(int amount) => OnTakeDamage?.Invoke(amount);
    public void TriggerDie() => OnDie?.Invoke();

    public Entity(EntityType type, int x, int y, int hp = 1, int damage = 1)
    {
        Type = type;
        X = x;
        Y = y;
        ID = EntityCount++;

        if (type == EntityType.Player)
        {
            HP = hp;
            Damage = damage;
        }
        else
        {
            float diff = TurnManager.Get().CurrentDifficulty;
            HP = Math.Max(1, (int)(hp * diff));
            Damage = Math.Max(1, (int)(damage * diff));
        }
    }

    public virtual void TakeDamage(int amount, Entity damager)
    {
        HP -= amount;
        TriggerTakeDamage(amount);
    }

    public virtual void Die(Entity killedBy)
    {
        World.Get().Player.Souls += 1;
        World.Get().Player.TriggerSoulGain(1);
        TriggerDie();
    }
    public virtual Intent? Think() { return null; }
}

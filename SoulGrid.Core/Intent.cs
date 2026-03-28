namespace SoulGrid.Core;

public record IntentResult(bool success, string? message = null, Intent? alternative = null);

public interface Intent
{
    IntentResult Execute(Entity owner);
}

public class MoveIntent : Intent
{
    public readonly int dx;
    public readonly int dy;

    public MoveIntent(int dx, int dy)
    {
        this.dx = dx;
        this.dy = dy;
    }

    public IntentResult Execute(Entity owner)
    {
        if (World.Get().Map.GetAt(owner.X + dx, owner.Y + dy) == TileType.Wall)
            return new IntentResult(false, "You bump into the wall.");

        Entity? target = World.Get().GetEntityAt(owner.X + dx, owner.Y + dy);
        if (target != null)
        {
            return new IntentResult(false, alternative: new BumpIntent(target, dx, dy));
        }

        owner.TriggerMove(owner.X, owner.Y, dx, dy);

        owner.X += dx;
        owner.Y += dy;

        if (owner.Type == EntityType.Player && (World.Get().Map.GetAt(owner.X, owner.Y) == TileType.Exit)) World.Get().NextFloor();

        return new IntentResult(true);
    }
}

public class BumpIntent : Intent
{
    private readonly Entity target;
    private readonly int dx;
    private readonly int dy;

    public BumpIntent(Entity target, int dx, int dy) { this.target = target; this.dx = dx; this.dy = dy; }
    public IntentResult Execute(Entity owner)
    {
        // Ignore enemy on enemy attacks
        if (owner.Type != EntityType.Player && target.Type != EntityType.Player) return new IntentResult(false);

        target.TakeDamage(owner.Damage, owner);
        if (!target.IsAlive) target.Die(owner);

        owner.TriggerAttack(target, owner.Damage, dx, dy);

        return new IntentResult(true, $"Entity {owner.ID} hits Entity {target.ID}.");
    }
}

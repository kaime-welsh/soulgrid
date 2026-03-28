namespace SoulGrid.Core.Entities;

public class Player(int x, int y) : Entity(EntityType.Player, x, y, 1, 1)
{
    public int Souls { get; set; } = 1;
    public event Action<int>? OnSoulsGained;
    public override int Damage => Math.Max(1, (int)(Souls * 0.15));

    public void TriggerSoulGain(int amount) => OnSoulsGained?.Invoke(amount);

    public override void TakeDamage(int amount, Entity damager)
    {
        this.TriggerTakeDamage(amount);
        Souls -= amount;
        Souls = Souls;
        if (Souls <= 0)
        {
            this.Die(damager);
        }
    }

    public override void Die(Entity killedBy)
    {
        World.Get().Restart();
    }
}

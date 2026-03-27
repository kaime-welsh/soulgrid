using SoulGrid.Core;
namespace SoulGrid.Entities;

public class Player : Entity
{
    public int Souls { get; set; } = 1;
    public event Action<int>? OnSoulsGained;
    public override int Damage => 1;

    public void TriggerSoulGain(int amount) => OnSoulsGained?.Invoke(amount);

    public Player(int x, int y) : base(EntityType.Player, x, y) { }
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

using System.Numerics;

using Raylib_cs;
using static Raylib_cs.Raylib;

using SoulGrid.Core;
using SoulGrid.Core.Entities;

namespace SoulGrid.Desktop;

public record RenderData(char Character, uint Color);
public enum GameState { AwaitingInput, PlayerTurn, EnemyTurn }

public class GameScene : Scene
{
    // Juice Variables
    private Dictionary<Entity, Vector2> visualPositions = new Dictionary<Entity, Vector2>();
    private float lerpSpeed = 25f;

    private struct DamagePop
    {
        public Vector2 Pos;
        public string Text;
        public float Life;
        public Color Color;
    };

    private Dictionary<Entity, Texture2D> entityTextures = new Dictionary<Entity, Texture2D>();
    private Dictionary<Vector2, Texture2D> tileTextures = new Dictionary<Vector2, Texture2D>();
    private Dictionary<Entity, Vector2> renderOffsets = new Dictionary<Entity, Vector2>();
    private Dictionary<Entity, float> flashTimers = new Dictionary<Entity, float>();
    private List<DamagePop> damagePops = new List<DamagePop>();

    private struct VisualEffect
    {
        public Vector2 Pos;
        public Texture2D Texture;
        public float Life;
    }
    private List<VisualEffect> activeEffects = new List<VisualEffect>();

    // Turn manager
    private Queue<Entity> turnQueue = new Queue<Entity>();
    private bool isProcessingTurns = false;
    private float sequenceTimer = 0f;
    private const float SequenceDelay = 0.005f;

    public static Dictionary<Core.TileType, RenderData> TileRenderLookup = new Dictionary<Core.TileType, RenderData>()
    {
        {TileType.Wall, new RenderData('#', Palette.Wall)},
        {TileType.Floor, new RenderData('.', Palette.Floor)},
        {TileType.Exit, new RenderData('>', Palette.Exit)},
    };

    public static Dictionary<Core.EntityType, RenderData> EntityRenderLookup = new Dictionary<Core.EntityType, RenderData>()
    {
        {EntityType.Player, new RenderData('@', Palette.Player)},
        {EntityType.Cultist, new RenderData('C', Palette.Cultist)}
    };

    private void SeedMapTextures()
    {
        tileTextures.Clear();
        var map = World.Get().Map;

        for (int y = 0; y < map.Height; y++)
        {
            for (int x = 0; x < map.Width; x++)
            {
                TileType type = map.GetAt(x, y);
                Vector2 pos = new Vector2(x, y);

                if (type == TileType.Wall)
                    tileTextures[pos] = Assets.Get().RandomTexture("wall");
                else if (type == TileType.Floor)
                    tileTextures[pos] = Assets.Get().RandomTexture("floor");
                else if (type == TileType.Exit)
                    tileTextures[pos] = Assets.Get().RandomTexture("door_open");
            }
        }
    }

    public override void OnEnter()
    {
        World.Get().OnReset += () =>
        {
            isProcessingTurns = false;
            turnQueue.Clear();

            visualPositions.Clear();
            renderOffsets.Clear();
            flashTimers.Clear();
            damagePops.Clear();
            entityTextures.Clear();

            SeedMapTextures();
            HookEntityEvents();
        };

        World.Get().NextFloor();
        SeedMapTextures();
        HookEntityEvents();
    }

    private void HookEntityEvents()
    {
        foreach (var entity in World.Get().Entities)
        {
            var e = entity;

            e.OnCreate += () =>
            {
                if (!entityTextures.ContainsKey(e))
                {
                    switch (e.Type)
                    {
                        case EntityType.Player:
                            entityTextures[e] = Assets.Get().Textures["demon"];
                            break;
                        case EntityType.Cultist:
                            entityTextures[e] = Assets.Get().RandomTexture("cultist");
                            break;
                        case EntityType.Villager:
                        case EntityType.Templar:
                            entityTextures[e] = Assets.Get().RandomTexture("villager");
                            break;
                        default:
                            entityTextures[e] = Assets.Get().Textures["unknown"];
                            break;
                    }
                }
            };

            e.TriggerCreate();

            e.OnTakeDamage += (amount) =>
            {
                flashTimers[e] = 0.15f;
                renderOffsets[e] = new Vector2((float)World.Get().Random.NextDouble() - 0.5f, 0) * 2f;

                damagePops.Add(new DamagePop
                {
                    Pos = new Vector2(e.X * GameSettings.CellSize, (e.Y * GameSettings.CellSize) - 4),
                    Text = $"-{amount}",
                    Life = 0.8f,
                    Color = Color.Red
                });

                activeEffects.Add(new VisualEffect
                {
                    Pos = new Vector2(e.X * GameSettings.CellSize, e.Y * GameSettings.CellSize),
                    Texture = Assets.Get().RandomTexture("attack_slash"),
                    Life = 0.15f
                });
            };

            if (e is Player p)
            {
                p.OnSoulsGained += (amount) =>
                {
                    damagePops.Add(new DamagePop
                    {
                        Pos = new Vector2(e.X * GameSettings.CellSize, (e.Y * GameSettings.CellSize) + 4),
                        Text = $"+{amount}",
                        Life = 0.8f,
                        Color = Color.Green
                    });
                };
            }

            e.OnAttack += (target, amount, dx, dy) =>
            {
                renderOffsets[e] = new Vector2(dx, dy) * (GameSettings.CellSize * 0.5f);
            };
        }
    }

    public override void Update(float dt)
    {
        if (TurnManager.Get().IsAwaitingPlayerInput)
        { // Gather player input and submit to TurnManager
            Intent? playerIntent = null;

            if (Input.Pressed(Input.Up)) playerIntent = new MoveIntent(0, -1);
            else if (Input.Pressed(Input.Down)) playerIntent = new MoveIntent(0, 1);
            else if (Input.Pressed(Input.Left)) playerIntent = new MoveIntent(-1, 0);
            else if (Input.Pressed(Input.Right)) playerIntent = new MoveIntent(1, 0);

            if (playerIntent != null)
            {
                TurnManager.Get().SubmitPlayerInput(playerIntent);
            }
        }

        // Use sequence timer to control visual speed of enemy turns
        sequenceTimer -= dt;
        if (sequenceTimer <= 0)
        {
            TurnManager.Get().Tick();
            sequenceTimer = SequenceDelay;
        }

        foreach (Entity entity in World.Get().Entities)
        {
            if (!entity.IsAlive) continue;

            Vector2 targetPos = new Vector2(entity.X * GameSettings.CellSize, entity.Y * GameSettings.CellSize);

            if (!visualPositions.ContainsKey(entity))
                visualPositions[entity] = targetPos;
            else
                visualPositions[entity] = Vector2.Lerp(visualPositions[entity], targetPos, lerpSpeed * dt);

            if (renderOffsets.ContainsKey(entity))
                renderOffsets[entity] = Vector2.Lerp(renderOffsets[entity], Vector2.Zero, 15f * dt);

            if (flashTimers.ContainsKey(entity))
                flashTimers[entity] -= dt;
        }

        for (int i = damagePops.Count - 1; i >= 0; i--)
        {
            var p = damagePops[i];
            p.Life -= dt;
            p.Pos.Y -= 10f * dt;
            damagePops[i] = p;
            if (p.Life <= 0) damagePops.RemoveAt(i);
        }

        for (int i = activeEffects.Count - 1; i >= 0; i--)
        {
            var fx = activeEffects[i];
            fx.Life -= dt;
            activeEffects[i] = fx;
            if (fx.Life <= 0) activeEffects.RemoveAt(i);
        }
    }

    public override void Draw()
    {
        // ClearBackground(new Color(15, 15, 15, 255));
        ClearBackground(Color.Black);

        var map = World.Get().Map;
        for (int y = 0; y < map.Height; y++)
        {
            for (int x = 0; x < map.Width; x++)
            {
                Vector2 gridPos = new Vector2(x, y);
                Vector2 screenPos = new Vector2(x * GameSettings.CellSize, y * GameSettings.CellSize);

                if (tileTextures.TryGetValue(gridPos, out Texture2D tex))
                {
                    TileType type = map.GetAt(x, y);
                    Color col = Assets.UnpackColor(TileRenderLookup[type].Color);

                    DrawTextureEx(tex, screenPos, 0.0f, 1.0f, col);
                }
                else if (map.GetAt(x, y) == TileType.Exit)
                {
                    DrawTextCodepoint(GetFontDefault(), '>', screenPos, GameSettings.CellSize, Color.Gold);
                }
            }
        }
        foreach (Core.Entity entity in World.Get().Entities)
        {
            if (!entity.IsAlive) continue;
            if (!visualPositions.ContainsKey(entity)) continue;

            Vector2 basePos = visualPositions[entity];
            Vector2 juiceOffset = renderOffsets.ContainsKey(entity) ? renderOffsets[entity] : Vector2.Zero;

            if (!entityTextures.TryGetValue(entity, out Texture2D texture))
            {
                texture = Assets.Get().Textures["unknown"];
            }

            Color color = Color.White;
            if (entity.Type == EntityType.Player) color = Assets.UnpackColor(Palette.Player);
            if (entity.Type == EntityType.Cultist) color = Assets.UnpackColor(Palette.Cultist);

            if (flashTimers.ContainsKey(entity) && flashTimers[entity] > 0) color = Color.Red;

            DrawTextureEx(
                texture,
                basePos + juiceOffset,
                0.0f,
                1.0f,
                color
            );

            if (entity.NextIntent != null && entity.NextIntent is MoveIntent dir)
            {
                int centerX = (entity.X * GameSettings.CellSize) + (GameSettings.CellSize / 2);
                int centerY = (entity.Y * GameSettings.CellSize) + (GameSettings.CellSize / 2);

                int offsetX = dir.dx * 6;
                int offsetY = dir.dy * 6;

                DrawRectangle(centerX + offsetX - 1, centerY + offsetY - 1, 2, 2, new Color(255, 255, 255, 255));
            }
        }

        foreach (var fx in activeEffects)
        {
            DrawTextureEx(fx.Texture, fx.Pos, 0f, 1.0f, new Color(255, 200, 200, 255));
        }

        foreach (var pop in damagePops)
        {
            Color textCol = Fade(pop.Color, pop.Life);
            DrawText(pop.Text, (int)pop.Pos.X, (int)(pop.Pos.Y - (1.0f - pop.Life) * 40f), 10, textCol);
        }

        DrawText(
            $"Floor {World.Get().CurrentFloor}",
            245, 5, 10, Assets.UnpackColor(Palette.White)
        );
        DrawText(
            $"Turns: {TurnManager.Get().TurnCount}",
            245, 15, 10, Assets.UnpackColor(Palette.White)
        );
        DrawText(
            $"Souls: {World.Get().Player.Souls}",
            245, 30, 10, Assets.UnpackColor(Palette.White)
        );
    }

    public override void Unload() { }
}

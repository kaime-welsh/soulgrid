namespace SoulGrid.Core;

public class Scene
{
    private static Stack<Scene> Scenes = new Stack<Scene>();

    public static void Push(Scene newScene)
    {
        Scenes.Push(newScene);
        newScene.OnEnter();
    }

    public static Scene Pop()
    {
        Scenes.Peek().Unload();
        return Scenes.Pop();
    }

    public static Scene Current()
    {
        return Scenes.Peek();
    }

    public static void UnloadAll()
    {
        while (Scenes.Count > 0)
        {
            Pop();
        }
    }

    public virtual void OnEnter() { }
    public virtual void Update(float dt) { }
    public virtual void Draw() { }
    public virtual void Unload() { }
}

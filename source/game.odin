package game
import "core"
import rl "vendor:raylib"

Scene :: enum {
	MAIN_MENU,
	NEW_RUN,
	IN_GAME,
	GAME_OVER,
}

Game_Memory :: struct {
	run:           bool,
	current_scene: Scene,
	game_state:    core.Game_State,
}
g: ^Game_Memory

GAME_WIDTH :: 320
GAME_HEIGHT :: 240

render_target: rl.RenderTexture2D

update :: proc() {
	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_update()
	case .NEW_RUN:
		new_run_update()
	case .IN_GAME:
		in_game_update()
	case .GAME_OVER:
		game_over_update()
	}
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_draw()
	case .NEW_RUN:
		new_run_draw()
	case .IN_GAME:
		in_game_draw()
	case .GAME_OVER:
		game_over_draw()
	}
	rl.EndDrawing()
}

@(export)
game_update :: proc() {
	update()
	draw()

	free_all(context.temp_allocator)
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "SOUL::GRID")
	rl.SetTargetFPS(60)
	rl.SetExitKey(nil)
}

@(export)
game_init :: proc() {
	g = new(Game_Memory)

	g^ = Game_Memory {
		run           = true,
		current_scene = .MAIN_MENU,
		game_state    = core.Game_State{},
	}

	game_hot_reloaded(g)
}

@(export)
game_should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		if rl.WindowShouldClose() {
			return false
		}
	}

	return g.run
}

@(export)
game_shutdown :: proc() {
	free(g)
}

@(export)
game_shutdown_window :: proc() {
	rl.UnloadRenderTexture(render_target)
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g = (^Game_Memory)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}

change_scene :: proc(next_scene: Scene) {
	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_exit()
	case .NEW_RUN:
		new_run_exit()
	case .IN_GAME:
		in_game_exit()
	case .GAME_OVER:
		game_over_exit()
	}

	g.current_scene = next_scene

	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_enter()
	case .NEW_RUN:
		new_run_enter()
	case .IN_GAME:
		in_game_enter()
	case .GAME_OVER:
		game_over_enter()
	}
}


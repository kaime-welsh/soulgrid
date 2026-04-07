package game
import "engine"
import rl "vendor:raylib"

Scene :: enum {
	MAIN_MENU,
	NEW_RUN,
	IN_GAME,
	GAME_OVER,
}

Game_Memory :: struct {
	run:                 bool,
	paused:              bool,
	render_scale:        f32,
	current_scene:       Scene,
	next_scene:          Scene,
	should_change_scene: bool,
	assets:              Assets,
	render_target:       rl.RenderTexture2D,
	turn_manager:        engine.Turn_Manager,
	world:               engine.World,
	map_texture:         rl.RenderTexture,
	render_data:         map[uint]Render_Data,
	camera_zoom:         f32,
}
g: ^Game_Memory

GAME_WIDTH :: 320
GAME_HEIGHT :: 240

update :: proc() {
	g.render_scale = min(
		f32(rl.GetScreenWidth()) / f32(GAME_WIDTH),
		f32(rl.GetScreenHeight()) / f32(GAME_HEIGHT),
	)

	rl.SetMouseOffset(
		-i32((f32(rl.GetScreenWidth()) - (f32(GAME_WIDTH) * g.render_scale)) * 0.5),
		-i32((f32(rl.GetScreenHeight()) - (f32(GAME_HEIGHT) * g.render_scale)) * 0.5),
	)
	rl.SetMouseScale(1 / g.render_scale, 1 / g.render_scale)

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

	if g.should_change_scene {
		g.should_change_scene = false
		perform_scene_change(g.next_scene)
	}
}

draw :: proc() {
	rl.BeginTextureMode(g.render_target)
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
	rl.EndTextureMode()

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.DrawTexturePro(
		g.render_target.texture,
		{0, 0, f32(g.render_target.texture.width), f32(-g.render_target.texture.height)}, // Flip vertically
		{
			(f32(rl.GetScreenWidth()) - (f32(GAME_WIDTH) * g.render_scale)) * 0.5,
			(f32(rl.GetScreenHeight()) - (f32(GAME_HEIGHT) * g.render_scale)) * 0.5,
			f32(GAME_WIDTH) * g.render_scale,
			f32(GAME_HEIGHT) * g.render_scale,
		},
		{0, 0},
		0,
		rl.WHITE,
	)
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
	rl.MaximizeWindow()
}

@(export)
game_init :: proc() {
	g = new(Game_Memory)

	g^ = Game_Memory {
		run           = true,
		current_scene = .MAIN_MENU,
		world         = engine.World{},
		render_target = rl.LoadRenderTexture(GAME_WIDTH, GAME_HEIGHT),
		assets        = Assets{},
		camera_zoom   = 1,
	}
	load_assets(&g.assets)

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

	unload_assets(&g.assets)
	delete(g.render_data)
	rl.UnloadRenderTexture(g.render_target)

	free(g)
}

@(export)
game_shutdown_window :: proc() {
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

	on_floor_change(&g.world) // reset render data
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
	g.next_scene = next_scene
	g.should_change_scene = true
}

perform_scene_change :: proc(next_scene: Scene) {
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


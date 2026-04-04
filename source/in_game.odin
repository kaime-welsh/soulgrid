package game

import core "core"
import rand "core:math/rand"
import rl "vendor:raylib"

on_floor_change :: proc(world: ^core.World) {
	populate_render_data()
}

on_player_died :: proc(entity: ^core.Entity, killed_by: ^core.Entity) {
	change_scene(.MAIN_MENU)
}

in_game_enter :: proc() {
	g.paused = false
	rand.reset(123456789, context.random_generator)
	clear(&g.render_data)

	g.world.floor_changed = on_floor_change

	core.world_init(&g.world, 20, 11)
	core.tm_init(&g.turn_manager, 0.005, 10.0)

	player := &g.world.entities[g.world.player_id]
	player.died = on_player_died
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if rl.IsKeyDown(.LEFT_CONTROL) &&
	   rl.IsKeyPressed(.R) {core.world_next_floor(&g.world); populate_render_data()}
	if g.paused {return}

	if g.turn_manager.turn_state == .WAITING_FOR_INPUT {
		player_command: core.Command
		input_received := false

		// TODO: mouse controls

		// keyboard controls
		if key_pressed(INPUT_KEY_UP) {
			player_command.type = core.Move_Command{0, -1}
			input_received = true
		} else if key_pressed(INPUT_KEY_DOWN) {
			player_command.type = core.Move_Command{0, 1}
			input_received = true
		} else if key_pressed(INPUT_KEY_LEFT) {
			player_command.type = core.Move_Command{-1, 0}
			input_received = true
		} else if key_pressed(INPUT_KEY_RIGHT) {
			player_command.type = core.Move_Command{1, 0}
			input_received = true
		}

		if input_received {
			core.tm_submit_input(&g.turn_manager, &g.world, &player_command)
		}
	}

	core.tm_tick(&g.turn_manager, &g.world)
	update_render_data()

}

in_game_draw :: proc() {
	for data in g.render_data {
		if !data.is_visible do continue
		switch val in data.type {
		case Tile_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		case Entity_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		case Damage_Pop_Render_Data:
		}
	}

	if g.paused {show_pause_menu()}
	rl.DrawFPS(2, 2)
}

in_game_exit :: proc() {
	core.world_destroy(&g.world)
	core.tm_destroy(&g.turn_manager)
}


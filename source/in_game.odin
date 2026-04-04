package game

import core "core"
import "core:fmt"
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
			core.tm_submit_input(&g.turn_manager, &g.world, player_command)
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
			enemy := &g.world.entities[val.entity_id]
			if enemy.next_command.type != nil {
				if cmd, ok := enemy.next_command.type.(core.Move_Command); ok {
					center := [2]f32 {
						f32(enemy.pos.x * 16) + (16 / 2),
						f32(enemy.pos.y * 16) + (16 / 2),
					}
					offset := [2]f32{f32(cmd.dx * 6), f32(cmd.dy * 6)}

					rl.DrawPixel(
						i32(center.x + offset.x - 1),
						i32(center.y + offset.y - 1),
						{255, 255, 255, 255},
					)
				}
			}
		case Damage_Pop_Render_Data:
		}
	}

	{ 	// draw ui
		ui_area := rl.Rectangle{4, 184, 312, 52}
		rl.DrawRectangle(0, 180, GAME_WIDTH, GAME_HEIGHT - 180, rl.WHITE)
		rl.DrawRectangle(2, 182, 316, 54, rl.BLACK)

		rl.DrawText(
			fmt.ctprintf("FLOOR: {}", g.world.current_floor),
			i32(ui_area.x),
			i32(ui_area.y),
			10,
			rl.WHITE,
		)

		rl.DrawText(
			fmt.ctprintf("Souls: {}", g.world.entities[g.world.player_id].hp),
			i32(ui_area.x),
			i32(ui_area.y + 12),
			10,
			rl.WHITE,
		)

		rl.DrawText(
			fmt.ctprintf("Difficulty: {}", i32(g.world.current_difficulty)),
			i32(ui_area.x),
			i32(ui_area.y + 24),
			10,
			rl.WHITE,
		)
	}

	rl.DrawText(
		fmt.ctprintf("{}:{}", rl.GetMouseX(), rl.GetMouseY()),
		rl.GetMouseX(),
		rl.GetMouseY(),
		10,
		rl.RED,
	)

	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
	core.world_destroy(&g.world)
	core.tm_destroy(&g.turn_manager)
}


package game

import core "core"
import "core:fmt"
import "core:math/linalg"
import rand "core:math/rand"
import rl "vendor:raylib"

on_floor_change :: proc(world: ^core.World) {
	render_map(&g.world)
	populate_render_data(&g.render_data, &g.world)

	for _, &entity in &g.world.entities {
		entity.moved = on_entity_moved
		entity.attacked = on_entity_attacked
		entity.took_damage = on_entity_took_damage
		entity.gained_souls = on_entity_gained_souls
		entity.died = on_entity_died
	}
}

on_entity_moved :: proc(entity: ^core.Entity, dx, dy: i32) {}

on_entity_attacked :: proc(entity: ^core.Entity, target: ^core.Entity, dx, dy: i32) {
	rd := &g.render_data[entity.id]
	rd.screen_pos += {f32(dx), f32(dy)} * 8
}

on_entity_took_damage :: proc(entity: ^core.Entity, amount: i32) {
	if entity.type == .PLAYER {
		g.camera_zoom = 0.95
	}
}

on_entity_gained_souls :: proc(entity: ^core.Entity, amount: i32) {}

on_entity_died :: proc(entity: ^core.Entity, killed_by: ^core.Entity) {
	if entity.type == .PLAYER {
		change_scene(.MAIN_MENU)
	}
}

in_game_enter :: proc() {
	g.paused = false
	rand.reset(123456789, context.random_generator)
	clear(&g.render_data)

	g.world.floor_changed = on_floor_change

	core.world_init(&g.world, 20, 11)
	core.tm_init(&g.turn_manager, 0.01, 10.0)

	for _, &entity in &g.world.entities {
		entity.moved = on_entity_moved
		entity.attacked = on_entity_attacked
		entity.took_damage = on_entity_took_damage
		entity.gained_souls = on_entity_gained_souls
		entity.died = on_entity_died
	}
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if rl.IsKeyDown(.LEFT_CONTROL) && rl.IsKeyPressed(.R) {
		core.world_next_floor(&g.world)
		populate_render_data(&g.render_data, &g.world)}
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
	update_render_data(&g.render_data, &g.world)
	g.camera_zoom = linalg.lerp(g.camera_zoom, 1, 0.3)
}

in_game_draw :: proc() {
	rl.ClearBackground({15, 15, 15, 255})
	rl.BeginMode2D(
		rl.Camera2D {
			offset = {f32((g.world.grid.width * 16) / 2), f32((g.world.grid.height * 16) / 2)},
			target = {
				f32((g.world.grid.width * 16) / 2),
				f32((g.world.grid.height * 16) / 2) - 16,
			},
			rotation = 0,
			zoom = g.camera_zoom,
		},
	)
	rl.DrawTexturePro(
		g.map_texture.texture,
		{0, 0, f32(g.map_texture.texture.width), f32(-g.map_texture.texture.height)}, // Flip vertically
		{0, 0, f32(g.map_texture.texture.width), f32(g.map_texture.texture.height)},
		{0, 0},
		0,
		rl.WHITE,
	)
	for _, data in g.render_data {
		if !data.is_visible do continue
		switch val in data.type {
		case Tile_Render_Data:
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
	rl.EndMode2D()

	{ 	// draw ui
		rl.DrawText(fmt.ctprintf("FLOOR: {}", g.world.current_floor), 0, 0, 10, rl.WHITE)
		rl.DrawText(fmt.ctprintf("Turn: {}", i32(g.turn_manager.turn_count)), 80, 0, 10, rl.WHITE)

		rl.DrawText(
			fmt.ctprintf("Souls: {}", g.world.entities[g.world.player_id].hp),
			160,
			0,
			10,
			rl.WHITE,
		)

		rl.DrawText(
			fmt.ctprintf("Difficulty: {}", i32(g.world.current_difficulty)),
			240,
			0,
			10,
			rl.WHITE,
		)

	}

	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
	rl.UnloadRenderTexture(g.map_texture)
	core.world_destroy(&g.world)
	core.tm_destroy(&g.turn_manager)
}


package game

import "core:math/linalg"
import engine "engine"
import rl "vendor:raylib"

in_game_enter :: proc() {
	g.paused = false
	clear(&g.render_data)

	g.world.floor_changed = on_floor_change

	engine.world_init(
		&g.world,
		20,
		10,
		engine.Drunk_Walker_Config {
			floor_percent = 0.6,
			turn_chance = 0.50,
			room_chance = 0.01,
			room_radius = 3,
			lifespan = 80,
		},
	)
	engine.tm_init(&g.turn_manager, 0.01, 10.0)
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if g.paused {return}

	if g.floor_enemy_count > 0 {
		if g.turn_manager.turn_state == .WAITING_FOR_INPUT {
			player_command: engine.Command
			input_received := false

			// TODO: mouse controls

			if key_pressed(INPUT_KEY_UP) {
				player_command.type = engine.Move_Command{0, -1}
				input_received = true
			} else if key_pressed(INPUT_KEY_DOWN) {
				player_command.type = engine.Move_Command{0, 1}
				input_received = true
			} else if key_pressed(INPUT_KEY_LEFT) {
				player_command.type = engine.Move_Command{-1, 0}
				input_received = true
			} else if key_pressed(INPUT_KEY_RIGHT) {
				player_command.type = engine.Move_Command{1, 0}
				input_received = true
			}

			if rl.IsKeyPressed(.R) {
				player_command.type = engine.Cast_Ability_Command({0})
				input_received = true
			}

			if input_received {
				engine.tm_submit_input(&g.turn_manager, &g.world, player_command)
			}
		}
		engine.tm_tick(&g.turn_manager, &g.world)
	} else {
		g.floor_cleared = true
	}
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
	// render_map
	rl.DrawTexturePro(
		g.map_texture.texture,
		{0, 0, f32(g.map_texture.texture.width), f32(-g.map_texture.texture.height)}, // Flip vertically
		{0, 0, f32(g.map_texture.texture.width), f32(g.map_texture.texture.height)},
		{0, 0},
		0,
		rl.WHITE,
	)
	render_entities()
	rl.EndMode2D()

	render_hud()
}

in_game_exit :: proc() {
	rl.UnloadRenderTexture(g.map_texture)
	engine.world_destroy(&g.world)
	engine.tm_destroy(&g.turn_manager)
}

//================ EVENT HOOKS ===============================

on_floor_change :: proc(world: ^engine.World) {
	g.floor_enemy_count = 0
	g.floor_cleared = false
	g.paused = false
	g.camera_zoom = 1

	render_map(&g.world)
	populate_render_data(&g.render_data, &g.world)

	for _, &entity in &g.world.entities {
		if entity.type != .PLAYER {g.floor_enemy_count += 1}

		entity.moved = on_entity_moved
		entity.attacked = on_entity_attacked
		entity.took_damage = on_entity_took_damage
		entity.gained_souls = on_entity_gained_souls
		entity.died = on_entity_died
	}
}

on_entity_moved :: proc(entity: ^engine.Entity, dx, dy: i32) {}

on_entity_attacked :: proc(entity: ^engine.Entity, target: ^engine.Entity, dx, dy: i32) {
	rd := &g.render_data[entity.id]
	rd.screen_pos += {f32(dx), f32(dy)} * 8
}

on_entity_took_damage :: proc(entity: ^engine.Entity, amount: i32) {
	if entity.type == .PLAYER {
		g.camera_zoom = 0.95
	}
}

on_entity_gained_souls :: proc(entity: ^engine.Entity, amount: i32) {}

on_entity_died :: proc(entity: ^engine.Entity, killed_by: ^engine.Entity) {
	if entity.type == .PLAYER {
		change_scene(.MAIN_MENU)
	}
	if entity.type != .PLAYER {g.floor_enemy_count -= 1}
}


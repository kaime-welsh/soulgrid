package game

import "core:math/rand"
import rl "vendor:raylib"

Tile_Render_Data :: struct {
	texture: rl.Texture2D,
}

Entity_Render_Data :: struct {
	entity_id: uint,
	offset:    [2]f32,
	texture:   rl.Texture2D,
}

Damage_Pop_Render_Data :: struct {}

Render_Data :: struct {
	screen_pos: [2]f32,
	color:      rl.Color,
	type:       union {
		Tile_Render_Data,
		Entity_Render_Data,
		Damage_Pop_Render_Data,
	},
}

populate_render_data :: proc() {
	// populate visual data from tilemap
	clear_dynamic_array(&g.render_data)
	for tile, idx in g.world.grid.cells {
		texture_name: string = ""
		color: rl.Color = rl.WHITE

		switch tile {
		case .EMPTY:
			continue
		case .WALL:
			wall_textures := []string {
				"wall_1",
				"wall_2",
				"wall_3",
				"wall_4",
				"wall_5",
				"wall_6",
				"wall_7",
			}
			texture_name = rand.choice(wall_textures)
			color = {0x33, 0x66, 0x55, 0xFF}
		case .FLOOR:
			floor_textures := []string {
				"floor_1",
				"floor_2",
				"floor_3",
				"floor_4",
				"floor_5",
				"floor_6",
			}
			texture_name = rand.choice(floor_textures)
			color = {0x22, 0x11, 0x44, 0xFF}
		case .EXIT:
			exit_textures := []string {
				"door_open_1",
				"door_open_2",
				"door_open_3",
				"door_open_4",
				"door_open_5",
				"door_open_6",
				"door_open_7",
			}
			texture_name = rand.choice(exit_textures)
			color = {0xDD, 0xFF, 0x33, 0xFF}
		}
		append(
			&g.render_data,
			Render_Data {
				[2]f32 {
					f32(i32(idx) % g.world.grid.width) * 16,
					f32(i32(idx) / g.world.grid.width) * 16,
				},
				color,
				Tile_Render_Data{texture = g.assets.textures[texture_name]},
			},
		)
	}

	// populate entity data
	for entity_id, entity in g.world.entities {
		screen_pos := [2]f32{f32(entity.pos.x * 16), f32(entity.pos.y * 16)}
		color := rl.MAGENTA
		texture: string = ""

		#partial switch entity.type {
		case .PLAYER:
			texture = "demon"
			color = {0x33, 0xEE, 0x66, 0xFF}
		case .CULTIST:
			cultist_textures := []string {
				"cultist_1",
				"cultist_2",
				"cultist_3",
				"cultist_4",
				"cultist_5",
				"cultist_6",
				"cultist_7",
			}
			texture = rand.choice(cultist_textures)
			color = {0xEE, 0x22, 0x77, 0xFF}
		}

		append(
			&g.render_data,
			Render_Data {
				screen_pos,
				color,
				Entity_Render_Data{entity_id, {0, 0}, g.assets.textures[texture]},
			},
		)
	}
}

update_render_data :: proc() {
	for &data in g.render_data {
		#partial switch val in data.type {
		case Entity_Render_Data:
			entity := &g.world.entities[val.entity_id]
			data.screen_pos = [2]f32{f32(entity.pos.x * 16), f32(entity.pos.y * 16)}
		}
	}
}


package game

import "core:math/rand"
import rl "vendor:raylib"

Tile_Render_Data :: struct {
	texture: rl.Texture2D,
}

Entity_Render_Data :: struct {
	offset:  [2]f32,
	texture: rl.Texture2D,
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
	for tile, idx in g.game_state.tile_map.tiles {
		texture_name: string = ""
		color: rl.Color = rl.WHITE

		switch tile {
		case .EMPTY:
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
			color = rl.DARKGREEN
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
			color = rl.DARKPURPLE
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
			color = rl.GOLD
		}
		append(
			&g.render_data,
			Render_Data {
				screen_pos = [2]f32 {
					f32(i32(idx) / g.game_state.tile_map.width) * 16,
					f32(i32(idx) % g.game_state.tile_map.width) * 16,
				},
				type = Tile_Render_Data{texture = g.assets.textures[texture_name]},
				color = color,
			},
		)
	}
}


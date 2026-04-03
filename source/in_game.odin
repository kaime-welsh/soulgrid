package game

import core "core"
import rl "vendor:raylib"

in_game_enter :: proc() {
	g.paused = false
	g.game_state.tile_map = core.tm_init(11, 20)
	request_next_floor()
}

request_next_floor :: proc() {
	core.tm_generate(
		&g.game_state.tile_map,
		core.Drunk_Walker_Config {
			directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}},
			floor_percent = 0.4,
			turn_chance = 0.20,
			room_chance = 0.01,
			room_radius = 2,
			lifespan = 100,
		},
	)
	populate_render_data()
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if rl.IsKeyDown(.LEFT_CONTROL) && rl.IsKeyPressed(.R) {request_next_floor()}
	if g.paused {return}
}

in_game_draw :: proc() {
	for data in g.render_data {
		#partial switch val in data.type {
		case Tile_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		case Entity_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		}
	}

	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
	delete(g.game_state.tile_map.tiles)
}


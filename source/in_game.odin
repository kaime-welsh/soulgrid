package game

import core "core"
import rl "vendor:raylib"

in_game_enter :: proc() {
	g.paused = false
	core.world_init(&g.world, 11, 20)
	populate_render_data()
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if rl.IsKeyDown(.LEFT_CONTROL) &&
	   rl.IsKeyPressed(.R) {core.world_next_floor(&g.world); populate_render_data()}
	if g.paused {return}
}

in_game_draw :: proc() {
	for data in g.render_data {
		switch val in data.type {
		case Tile_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		case Entity_Render_Data:
			rl.DrawTextureEx(val.texture, data.screen_pos, 0.0, 1, data.color)
		case Damage_Pop_Render_Data:
		}
	}

	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
	delete(g.world.tile_map.tiles)
}


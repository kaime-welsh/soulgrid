package game

import rl "vendor:raylib"

in_game_enter :: proc() {
	g.paused = false
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if g.paused {return}
}

in_game_draw :: proc() {
	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
}


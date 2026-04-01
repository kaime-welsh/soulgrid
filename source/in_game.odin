package game

import rl "vendor:raylib"

in_game_enter :: proc() {
	g.paused = false

	g.assets.textures["player"] = rl.LoadTexture("assets/monsters/demon.png")
}

in_game_update :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {g.paused = !g.paused}
	if g.paused {return}
}

in_game_draw :: proc() {
	if g.paused {show_pause_menu()}
}

in_game_exit :: proc() {
	rl.UnloadTexture(g.assets.textures["player"])
}


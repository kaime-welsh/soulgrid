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
	if g.paused {
		rl.DrawRectangle(
			GAME_WIDTH / 4 - 1,
			GAME_HEIGHT / 4 - 1,
			GAME_WIDTH / 2 + 2,
			GAME_HEIGHT / 2 + 2,
			rl.WHITE,
		)
		rl.DrawRectangle(
			GAME_WIDTH / 4,
			GAME_HEIGHT / 4,
			GAME_WIDTH / 2,
			GAME_HEIGHT / 2,
			{15, 15, 15, 255},
		)

		draw_text_centered(
			rl.GetFontDefault(),
			"PAUSED",
			{GAME_WIDTH / 2, GAME_HEIGHT / 3},
			30,
			8,
			rl.WHITE,
		)


		if ui_button_center({(GAME_WIDTH / 2), (GAME_HEIGHT / 2)}, "RESUME", 20) {
			g.paused = false
		}

		if ui_button_center({(GAME_WIDTH / 2), (GAME_HEIGHT / 2 + 24)}, "QUIT", 20) {
			change_scene(.MAIN_MENU)
		}
	}
}

in_game_exit :: proc() {}


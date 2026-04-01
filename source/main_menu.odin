package game

import rl "vendor:raylib"

main_menu_enter :: proc() {}

main_menu_update :: proc() {}

main_menu_draw :: proc() {
	draw_text_centered(
		rl.GetFontDefault(),
		"SOUL::GRID",
		{(GAME_WIDTH / 2), (GAME_HEIGHT / 3)},
		48,
		2.0,
		rl.WHITE,
	)

	text_size := rl.MeasureTextEx(rl.GetFontDefault(), "NEW RUN", 24, 1.0)
	if rl.GuiButton(
		{
			(GAME_WIDTH / 2) - (text_size.x / 2),
			(GAME_HEIGHT / 2) - (text_size.y / 2),
			text_size.x,
			text_size.y,
		},
		"NEW RUN",
	) {
		change_scene(.NEW_RUN)
	}
	when ODIN_OS != .JS { 	// quit button shouldn't exist on web
		text_size = rl.MeasureTextEx(rl.GetFontDefault(), "QUIT", 24, 1.0)
		if rl.GuiButton(
			{
				(GAME_WIDTH / 2) - (text_size.x / 2),
				(GAME_HEIGHT / 2) - (text_size.y / 2) + 32,
				text_size.x,
				text_size.y,
			},
			"QUIT",
		) {
			g.run = false}
	}
}

main_menu_exit :: proc() {}


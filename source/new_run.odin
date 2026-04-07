package game

import "core:math/rand"
import rl "vendor:raylib"

buffer: [80]byte = {}
seed_text: cstring = cstring(&buffer[0])
editing := true

new_run_enter :: proc() {
	rand.reset(g.seed, context.random_generator)
	change_scene(.IN_GAME) // For now skip
}

new_run_update :: proc() {}

new_run_draw :: proc() {
	rl.GuiLabel({f32(GAME_WIDTH / 4), f32(GAME_HEIGHT / 2) - 32, f32(GAME_WIDTH / 2), 16}, "Seed:")

	if rl.GuiTextBox(
		{f32(GAME_WIDTH / 4), f32(GAME_HEIGHT / 2) - 16, f32(GAME_WIDTH / 2), 16},
		seed_text,
		80,
		editing,
	) {
		change_scene(.IN_GAME)
		rand.reset_bytes(transmute([]u8)string(seed_text), context.random_generator)
	}
}

new_run_exit :: proc() {}


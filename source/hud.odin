package game

import "core:fmt"
import "engine"
import rl "vendor:raylib"

render_hud :: proc() { 	// draw ui
	rl.DrawText(fmt.ctprintf("FLOOR: {}", g.world.current_floor), 0, 0, 10, rl.WHITE)
	rl.DrawText(fmt.ctprintf("Turn: {}", i32(g.turn_manager.turn_count)), 80, 0, 10, rl.WHITE)

	rl.DrawText(
		fmt.ctprintf("Souls: {}", g.world.entities[g.world.player_id].hp),
		160,
		0,
		10,
		rl.WHITE,
	)

	rl.DrawText(
		fmt.ctprintf("Difficulty: {}", i32(g.world.current_difficulty)),
		240,
		0,
		10,
		rl.WHITE,
	)
	rl.DrawText(fmt.ctprintf("{}", i32(g.floor_enemy_count)), 220, 0, 10, rl.WHITE)

	if g.floor_cleared {
		rl.DrawRectangle(0, 0, GAME_WIDTH, GAME_HEIGHT, {0, 0, 0, 100})
		if ui_button_center({f32(GAME_WIDTH / 2), f32(GAME_HEIGHT / 2)}, "NEXT FLOOR", 20, 1.0) {
			engine.world_next_floor(&g.world)
		}
	}

	if g.paused {
		rl.DrawRectangle(0, 0, GAME_WIDTH, GAME_HEIGHT, {0, 0, 0, 100})
		show_pause_menu()
	}
}


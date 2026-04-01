// Wraps os.read_entire_file and os.write_entire_file, but they also work with emscripten.

package game

@(require_results)
read_entire_file :: proc(
	name: string,
	allocator := context.allocator,
	loc := #caller_location,
) -> (
	data: []byte,
	success: bool,
) {
	return _read_entire_file(name, allocator, loc)
}

write_entire_file :: proc(name: string, data: []byte, truncate := true) -> (success: bool) {
	return _write_entire_file(name, data, truncate)
}

change_scene :: proc(next_scene: Scene) {
	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_exit()
	case .NEW_RUN:
		new_run_exit()
	case .IN_GAME:
		in_game_exit()
	case .GAME_OVER:
		game_over_exit()
	}

	g.current_scene = next_scene

	switch g.current_scene {
	case .MAIN_MENU:
		main_menu_enter()
	case .NEW_RUN:
		new_run_enter()
	case .IN_GAME:
		in_game_enter()
	case .GAME_OVER:
		game_over_enter()
	}
}


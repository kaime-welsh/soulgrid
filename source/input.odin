package game

import rl "vendor:raylib"

INPUT_KEY_UP :: []rl.KeyboardKey{.W, .UP, .K}
INPUT_KEY_DOWN :: []rl.KeyboardKey{.S, .DOWN, .J}
INPUT_KEY_LEFT :: []rl.KeyboardKey{.A, .LEFT, .H}
INPUT_KEY_RIGHT :: []rl.KeyboardKey{.D, .RIGHT, .L}

key_pressed :: proc(keys: []rl.KeyboardKey, repeat: bool = true) -> bool {
	for key in keys {
		if repeat {
			if rl.IsKeyPressed(key) || rl.IsKeyPressedRepeat(key) {
				return true
			}
		} else {
			if rl.IsKeyPressed(key) {
				return true
			}
		}
	}

	return false
}


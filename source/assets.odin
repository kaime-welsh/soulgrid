package game

import rl "vendor:raylib"

Assets :: struct {
	textures: map[string]rl.Texture2D,
	fonts:    map[string]rl.Font,
	sounds:   map[string]rl.Sound,
	music:    map[string]rl.Music,
}

load_assets :: proc(assets: Assets) {}


package game

import rl "vendor:raylib"

Assets :: struct {
	textures: map[string]rl.Texture2D,
	fonts:    map[string]rl.Font,
	sounds:   map[string]rl.Sound,
	music:    map[string]rl.Music,
}

load_assets :: proc(assets: ^Assets) {
	assets.textures["demon"] = rl.LoadTexture("assets/monsters/demon.png")

	assets.textures["wall_1"] = rl.LoadTexture("assets/walls/wall_1.png")
	assets.textures["wall_2"] = rl.LoadTexture("assets/walls/wall_2.png")
	assets.textures["wall_3"] = rl.LoadTexture("assets/walls/wall_3.png")
	assets.textures["wall_4"] = rl.LoadTexture("assets/walls/wall_4.png")
	assets.textures["wall_5"] = rl.LoadTexture("assets/walls/wall_5.png")
	assets.textures["wall_6"] = rl.LoadTexture("assets/walls/wall_6.png")
	assets.textures["wall_7"] = rl.LoadTexture("assets/walls/wall_7.png")

	assets.textures["floor_1"] = rl.LoadTexture("assets/floors/floor_1.png")
	assets.textures["floor_2"] = rl.LoadTexture("assets/floors/floor_2.png")
	assets.textures["floor_3"] = rl.LoadTexture("assets/floors/floor_3.png")
	assets.textures["floor_4"] = rl.LoadTexture("assets/floors/floor_4.png")
	assets.textures["floor_5"] = rl.LoadTexture("assets/floors/floor_5.png")
	assets.textures["floor_6"] = rl.LoadTexture("assets/floors/floor_6.png")

	assets.textures["door_open_1"] = rl.LoadTexture("assets/doors_open/door_open_1.png")
	assets.textures["door_open_2"] = rl.LoadTexture("assets/doors_open/door_open_2.png")
	assets.textures["door_open_3"] = rl.LoadTexture("assets/doors_open/door_open_3.png")
	assets.textures["door_open_4"] = rl.LoadTexture("assets/doors_open/door_open_4.png")
	assets.textures["door_open_5"] = rl.LoadTexture("assets/doors_open/door_open_5.png")
	assets.textures["door_open_6"] = rl.LoadTexture("assets/doors_open/door_open_6.png")
	assets.textures["door_open_7"] = rl.LoadTexture("assets/doors_open/door_open_7.png")
}

unload_assets :: proc(assets: ^Assets) {}


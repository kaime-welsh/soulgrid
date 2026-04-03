package game

import rl "vendor:raylib"

Assets :: struct {
	textures: map[string]rl.Texture2D,
	fonts:    map[string]rl.Font,
	sounds:   map[string]rl.Sound,
	music:    map[string]rl.Music,
}

load_assets :: proc(assets: ^Assets) {
	assets.textures = make(map[string]rl.Texture2D)
	assets.fonts = make(map[string]rl.Font)
	assets.sounds = make(map[string]rl.Sound)
	assets.music = make(map[string]rl.Music)

	assets.textures["demon"] = rl.LoadTexture("assets/monsters/demon.png")

	assets.textures["cultist_1"] = rl.LoadTexture("assets/cultists/cultist_1.png")
	assets.textures["cultist_2"] = rl.LoadTexture("assets/cultists/cultist_2.png")
	assets.textures["cultist_3"] = rl.LoadTexture("assets/cultists/cultist_3.png")
	assets.textures["cultist_4"] = rl.LoadTexture("assets/cultists/cultist_4.png")
	assets.textures["cultist_5"] = rl.LoadTexture("assets/cultists/cultist_5.png")
	assets.textures["cultist_6"] = rl.LoadTexture("assets/cultists/cultist_6.png")
	assets.textures["cultist_7"] = rl.LoadTexture("assets/cultists/cultist_7.png")

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

unload_assets :: proc(assets: ^Assets) {
	for _, texture in assets.textures {
		rl.UnloadTexture(texture)
	}
	delete(assets.textures)

	for _, font in assets.fonts {
		rl.UnloadFont(font)
	}
	delete(assets.fonts)

	for _, sound in assets.sounds {
		rl.UnloadSound(sound)
	}
	delete(assets.sounds)

	for _, music in assets.music {
		rl.UnloadMusicStream(music)
	}
	delete(assets.music)
}


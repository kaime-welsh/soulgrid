package core

import "core:math/rand"
World :: struct {
	tile_map:      Tile_Map,
	entities:      map[uint]Entity,
	player:        ^Entity,
	current_floor: uint,
}

world_init :: proc(world: ^World, width, height: i32) {
	world_reset(world, width, height)
	world_next_floor(world)
}

world_reset :: proc(world: ^World, width, height: i32) {
	world.tile_map = tm_init(height, width)
}

world_get_entity_at :: proc(world: ^World, x, y: i32) -> uint {
	for id, &entity in world.entities {
		if entity.pos.x == x && entity.pos.y == y {return id}
	}
	return 0 // 0 should always be skipped when making entities
}

world_next_floor :: proc(world: ^World) {
	tm_generate(
		&world.tile_map,
		Drunk_Walker_Config {
			directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}},
			floor_percent = 0.4,
			turn_chance = 0.20,
			room_chance = 0.01,
			room_radius = 2,
			lifespan = 100,
		},
	)
	player_pos := rand.choice(world.tile_map.open_tiles[:])
	world.entities[0] = make_player(player_pos.x, player_pos.y)
	world.player = &world.entities[0]
}


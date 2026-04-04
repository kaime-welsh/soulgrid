package core

import "core:math/rand"
World :: struct {
	grid:               Grid,
	entities:           map[uint]Entity,
	player_id:          uint,
	current_floor:      uint,
	just_changed_floor: bool,
	floor_changed:      proc(world: ^World),
}

world_init :: proc(world: ^World, width, height: i32) {
	world_reset(world, width, height)
	world.player_id = world_add_entity(world, .PLAYER, 0, 0)
	world_next_floor(world)
}

world_add_entity :: proc(world: ^World, type: Entity_Type, x, y: i32) -> uint {
	entity_id := entity_count
	entity_count += 1

	#partial switch type {
	case .PLAYER:
		world.entities[entity_id] = make_player(x, y)
	case .CULTIST:
		world.entities[entity_id] = make_cultist(x, y)
	}
	return entity_id
}

world_reset :: proc(world: ^World, width, height: i32) {
	world.current_floor = 1
	world.grid = grid_init(height, width)
	grid_generate(&world.grid, {})
}

world_get_entity_at :: proc(world: ^World, x, y: i32) -> uint {
	for id, &entity in world.entities {
		if entity.pos.x == x && entity.pos.y == y {return id}
	}
	return 0 // 0 should always be skipped when making entities
}

world_next_floor :: proc(world: ^World) {
	grid_generate(
		&world.grid,
		Drunk_Walker_Config {
			directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}},
			floor_percent = 0.4,
			turn_chance = 0.20,
			room_chance = 0.01,
			room_radius = 2,
			lifespan = 100,
		},
	)

	player_pos := rand.choice(world.grid.open_tiles[:])
	player := &world.entities[world.player_id]
	player.pos = player_pos

	world.just_changed_floor = true
	world.floor_changed(world)
}


world_destroy :: proc(world: ^World) {
	delete(world.entities)
	delete(world.grid.open_tiles)
	delete(world.grid.cells)
}


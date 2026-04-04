package core

import "core:math/rand"
World :: struct {
	grid:               Grid,
	entities:           map[uint]Entity,
	entity_count:       uint,
	player_id:          uint,
	current_floor:      uint,
	just_changed_floor: bool,
	floor_changed:      proc(world: ^World),
	current_difficulty: f32,
}

world_init :: proc(world: ^World, width, height: i32) {
	world.entity_count = 1
	world.entities = make(map[uint]Entity)
	world_reset(world, width, height)
	world.player_id = world_add_entity(world, .PLAYER, 0, 0)
	world_next_floor(world)
}

world_add_entity :: proc(world: ^World, type: Entity_Type, x, y: i32) -> uint {
	entity_id := world.entity_count
	world.entity_count += 1

	#partial switch type {
	case .PLAYER:
		world.entities[entity_id] = make_player(x, y)
	case .CULTIST:
		world.entities[entity_id] = make_cultist(x, y)
	}

	ptr := &world.entities[entity_id]
	ptr.id = entity_id
	return entity_id
}
world_reset :: proc(world: ^World, width, height: i32) {
	world.current_floor = 0
	world.grid = grid_init(width, height)
}

world_get_entity_at :: proc(world: ^World, x, y: i32) -> uint {
	for id, &entity in world.entities {
		if entity.pos.x == x && entity.pos.y == y {return id}
	}
	return 0 // 0 should always be skipped when making entities
}

world_next_floor :: proc(world: ^World) {
	world.current_floor += 1

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

	// Keep player, remove everyone else
	for id in world.entities {
		if id != world.player_id {
			delete_key(&world.entities, id)
		}
	}

	player_ptr := &world.entities[world.player_id]
	player_ptr.next_command.type = nil


	open_tiles := make([dynamic][2]i32, len(world.grid.open_tiles))
	copy(open_tiles[:], world.grid.open_tiles[:])
	defer delete(open_tiles)
	rand.shuffle(open_tiles[:])

	if len(open_tiles) > 0 {
		player_pos := pop(&open_tiles)
		player := &world.entities[world.player_id]
		player.pos = player_pos
	}

	mob_count := ((world.current_floor + rand.uint_range(1, 3)) + uint(world.current_difficulty))
	for _ in 0 ..< min(mob_count, uint(f32((world.grid.width * world.grid.height)) * 0.10)) {
		if len(open_tiles) == 0 do break
		entity_pos := pop(&open_tiles)
		world_add_entity(world, .CULTIST, entity_pos.x, entity_pos.y)
	}

	world.just_changed_floor = true
	world.floor_changed(world)
}


world_destroy :: proc(world: ^World) {
	delete(world.entities)
	world.entities = nil
	grid_destroy(&world.grid)
}


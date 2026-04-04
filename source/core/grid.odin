package core

Cell_Type :: enum {
	EMPTY,
	WALL,
	FLOOR,
	EXIT,
}

Grid :: struct {
	width:      i32,
	height:     i32,
	cells:      []Cell_Type,
	open_tiles: [dynamic][2]i32,
}

Drunk_Walker_Config :: struct {
	directions:    [][2]i32,
	floor_percent: f32,
	turn_chance:   f32,
	room_chance:   f32,
	room_radius:   i32,
	lifespan:      int,
}

import "core:/math/rand"

grid_init :: proc(width, height: i32) -> Grid {
	return Grid{width, height, make([]Cell_Type, width * height), make([dynamic][2]i32)}
}

grid_in_bounds :: proc(tm: ^Grid, x, y: i32) -> bool {return(
		x >= 0 &&
		x < tm.width &&
		y >= 0 &&
		y < tm.height \
	)}

grid_get_at :: proc(tm: ^Grid, x, y: i32) -> Cell_Type {
	if grid_in_bounds(tm, x, y) {return tm.cells[y * tm.width + x]}
	return .WALL
}

grid_set_at :: proc(tm: ^Grid, x, y: i32, new_tile: Cell_Type) {
	if grid_in_bounds(tm, x, y) {
		tm.cells[y * tm.width + x] = new_tile
	}
}

grid_generate :: proc(tm: ^Grid, config: Drunk_Walker_Config) {
	// fill array with empty tiles
	for i in 0 ..< len(tm.cells) {
		tm.cells[i] = .EMPTY
	}

	clear(&tm.open_tiles)

	{ 	// drunk walk
		target_floor_count := int(f32(tm.width - 2) * f32(tm.height - 2) * config.floor_percent)
		walker_pos := [2]i32{tm.width / 2, tm.height / 2}
		walker_dir := rand.choice(config.directions)
		walker_lifespan := 0

		for len(tm.open_tiles) < target_floor_count {
			// walker has surpassed lifespan, but need more tiles, create new walker in an existing open tile
			if walker_lifespan >= config.lifespan && len(tm.open_tiles) > 0 {
				walker_pos = rand.choice(tm.open_tiles[:])
				walker_dir = rand.choice(config.directions)
				walker_lifespan = 0
			}

			if rand.float32() < config.room_chance { 	// stamp a random room
				room_radius: i32 = rand.int32_range(1, config.room_radius)
				for rx: i32 = -room_radius; rx <= room_radius; rx += 1 {
					for ry: i32 = -room_radius; ry <= room_radius; ry += 1 {
						stamp := [2]i32{walker_pos.x + rx, walker_pos.y + ry}
						if (stamp.x > 0 &&
							   stamp.x < tm.width - 1 &&
							   stamp.y > 0 &&
							   stamp.y < tm.height - 1) {
							if (grid_get_at(tm, stamp.x, stamp.y) != .FLOOR) {
								grid_set_at(tm, stamp.x, stamp.y, .FLOOR)
								append(&tm.open_tiles, stamp)
							}
						}
					}
				}
			} else { 	// place a single floor
				if grid_get_at(tm, walker_pos.x, walker_pos.y) != .FLOOR {
					grid_set_at(tm, walker_pos.x, walker_pos.y, .FLOOR)
					append(&tm.open_tiles, walker_pos)
				}
			}

			if rand.float32() < config.turn_chance { 	// turn random direction
				walker_dir = rand.choice(config.directions)
			}

			next_pos := walker_pos + walker_dir
			if next_pos.x > 0 &&
			   next_pos.x < tm.width - 1 &&
			   next_pos.y > 0 &&
			   next_pos.y < tm.height - 1 {
				walker_pos += walker_dir
			} else {
				walker_dir = rand.choice(config.directions)}

			walker_lifespan += 1
		}
	}

	{ 	// place walls
		for y: i32; y < tm.height; y += 1 {
			for x: i32 = 0; x < tm.width; x += 1 {
				if grid_get_at(tm, x, y) != .EMPTY {continue}
				for ny in -1 ..= 1 {
					for nx in -1 ..= 1 {
						dir := [2]i32{i32(nx), i32(ny)}
						if grid_get_at(tm, x + dir.x, y + dir.y) == .FLOOR {
							grid_set_at(tm, x, y, .WALL)
						}
					}
				}
			}
		}
	}

	{ 	// place exits
		potential_exits := make([dynamic][2]i32, context.temp_allocator)
		defer delete(potential_exits)

		for pos in tm.open_tiles {
			for dir in config.directions {
				check_pos := pos + dir
				if grid_get_at(tm, check_pos.x, check_pos.y) == .WALL {
					array_contains := false
					for exit_pos in potential_exits {
						if check_pos == exit_pos {
							array_contains = true
						}
					}

					if !array_contains {append(&potential_exits, check_pos)}
				}
			}
		}

		if len(potential_exits) > 0 {
			exit_pos := rand.choice(potential_exits[:])
			grid_set_at(tm, exit_pos.x, exit_pos.y, .EXIT)
		}
	}
}


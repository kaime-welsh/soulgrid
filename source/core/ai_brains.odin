package core

import "core:math/rand"

culist_think :: proc(world: ^World, self: ^Entity, player: ^Entity) {
	diff := player.pos - self.pos

	ideal := [2]i32{diff.x > 0 ? 1 : (diff.x < 0 ? -1 : 0), diff.y > 0 ? 1 : (diff.y < 0 ? -1 : 0)}

	primary_dirs: [dynamic][2]i32 = make([dynamic][2]i32, context.temp_allocator)
	if ideal.x != 0 do append(&primary_dirs, [2]i32{ideal.x, 0})
	if ideal.y != 0 do append(&primary_dirs, [2]i32{0, ideal.y})

	if len(primary_dirs) == 2 && rand.int32_range(0, 2) == 0 {
		primary_dirs[0], primary_dirs[1] = primary_dirs[1], primary_dirs[0]
	}

	all_cardinals := [4][2]i32{{0, 1}, {0, -1}, {1, 0}, {-1, 0}}
	fallbacks: [dynamic][2]i32 = make([dynamic][2]i32, context.temp_allocator)
	for dir in all_cardinals {
		is_primary := false
		for pd in primary_dirs {
			if pd == dir {
				is_primary = true
				break
			}
		}
		if !is_primary do append(&fallbacks, dir)
	}
	rand.shuffle(fallbacks[:])

	test_dirs: [dynamic][2]i32 = make([dynamic][2]i32, context.temp_allocator)
	for pd in primary_dirs do append(&test_dirs, pd)
	for fb in fallbacks do append(&test_dirs, fb)

	for dir in test_dirs {
		if dir == {0, 0} do continue

		check_pos := self.pos + dir
		if grid_get_at(&world.grid, check_pos.x, check_pos.y) == .WALL do continue

		occupant_id := world_get_entity_at(world, check_pos.x, check_pos.y)
		if occupant_id != 0 && occupant_id != world.player_id do continue

		self.next_command.type = Move_Command{dir.x, dir.y}
		return
	}
}


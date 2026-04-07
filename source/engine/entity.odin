package engine

Entity_Type :: enum {
	PLAYER,
	CULTIST,
	VILLAGER,
	TEMPLAR,
}

Entity :: struct {
	id:           uint,
	type:         Entity_Type,
	pos:          [2]i32,
	hp:           i32,
	damage:       i32,
	is_alive:     bool,
	next_command: Command,
	moved:        proc(entity: ^Entity, dx, dy: i32),
	attacked:     proc(entity: ^Entity, target: ^Entity, dx, dy: i32),
	took_damage:  proc(entity: ^Entity, amount: i32),
	gained_souls: proc(entity: ^Entity, amount: i32),
	died:         proc(entity: ^Entity, killed_by: ^Entity),
}

Null_Entity :: Entity{}

entity_current_damage :: proc(entity: ^Entity, world: ^World) -> i32 {
	return i32(max(1, f32(entity.damage) * world.current_difficulty * 1.25))
}

entity_take_damage :: proc(entity: ^Entity, amount: i32) {
	if !entity.is_alive do return

	entity.hp -= amount
	if entity.took_damage != nil {
		entity.took_damage(entity, amount)
	}

	if entity.hp <= 0 {
		entity.hp = 0
		entity.is_alive = false
	}
}

entity_die :: proc(world: ^World, entity: ^Entity) {
	player_ptr := &world.entities[world.player_id]
	if entity.type != .PLAYER {
		player_ptr.hp += 1
		if player_ptr.gained_souls != nil {
			player_ptr.gained_souls(player_ptr, 1)
		}
		if entity.died != nil {
			entity.died(entity, player_ptr)
		}
		delete_key(&world.entities, entity.id)
	} else {
		if entity.died != nil {
			entity.died(player_ptr, entity)
		}
	}
}

make_player :: proc(x, y: i32) -> Entity {
	return Entity{type = .PLAYER, pos = [2]i32{x, y}, hp = 1, damage = 1, is_alive = true}
}

make_cultist :: proc(x, y: i32) -> Entity {
	return Entity{type = .CULTIST, pos = [2]i32{x, y}, hp = 1, damage = 1, is_alive = true}
}


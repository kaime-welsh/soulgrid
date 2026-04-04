package core

Entity_Type :: enum {
	PLAYER,
	CULTIST,
	VILLAGER,
	TEMPLAR,
}

Entity :: struct {
	type:         Entity_Type,
	pos:          [2]i32,
	hp:           i32,
	max_hp:       i32,
	damage:       i32,
	is_alive:     bool,
	next_command: ^Command,
}
entity_count: uint = 1

Null_Entity :: Entity{}

entity_take_damage :: proc(entity: ^Entity, amount: i32) {
	entity.hp -= amount
	if entity.hp <= 0 {
		entity.is_alive = false
	}
}

make_player :: proc(x, y: i32) -> Entity {
	return Entity {
		type = .PLAYER,
		pos = [2]i32{x, y},
		hp = 1,
		max_hp = 1,
		damage = 1,
		is_alive = true,
	}
}

make_cultist :: proc(x, y: i32) -> Entity {
	return Entity {
		type = .CULTIST,
		pos = [2]i32{x, y},
		hp = 1,
		max_hp = 1,
		damage = 1,
		is_alive = true,
	}
}


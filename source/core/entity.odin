package core

Entity_Type :: enum {
	PLAYER,
	CULTIST,
	VILLAGER,
	TEMPLAR,
}

Entity :: struct {
	type:     Entity_Type,
	id:       uint,
	pos:      [2]i32,
	hp:       i32,
	max_hp:   i32,
	damage:   i32,
	is_alive: bool,
}
entity_count: uint = 0

Null_Entity :: Entity{}

entity_take_damage :: proc(entity: ^Entity, amount: i32) {
	entity.hp -= amount
	if entity.hp <= 0 {
		entity.is_alive = false
	}
}

make_player :: proc(x, y: i32) -> Entity {
	entity_count += 1
	return Entity {
		type = .PLAYER,
		id = entity_count,
		pos = [2]i32{x, y},
		hp = 1,
		max_hp = 1,
		damage = 1,
		is_alive = true,
	}
}

make_cultist :: proc(x, y: i32) -> Entity {
	entity_count += 1
	return Entity {
		type = .CULTIST,
		id = entity_count,
		pos = [2]i32{x, y},
		hp = 1,
		max_hp = 1,
		damage = 1,
		is_alive = true,
	}
}


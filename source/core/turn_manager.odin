package core

import "core:container/queue"

Turn_State :: enum {
	WAITING_FOR_INPUT,
	RESOLVING_PLAYER,
	RESOLVING_ENEMIES,
}

Turn_Manager :: struct {
	turn_state:        Turn_State,
	turn_queue:        queue.Queue(^Entity),
	difficulty_scalar: f32,
	max_difficulty:    f32,
	turn_count:        int,
}

tm_init :: proc(tm: ^Turn_Manager, diff_scalar, max_diff: f32) {
	tm.turn_state = .WAITING_FOR_INPUT
	tm.difficulty_scalar = diff_scalar
	tm.max_difficulty = max_diff
	tm.turn_count = 0
	tm.turn_queue = {}
}

tm_destroy :: proc(tm: ^Turn_Manager) {
	queue.destroy(&tm.turn_queue)
	tm.turn_queue = {}
}

tm_current_diff :: proc(tm: ^Turn_Manager) -> f32 {
	return min(tm.max_difficulty, 1.0 + (f32(tm.turn_count) * tm.difficulty_scalar))
}

tm_submit_input :: proc(tm: ^Turn_Manager, world: ^World, cmd: Command) {
	if tm.turn_state != .WAITING_FOR_INPUT {return}
	world.just_changed_floor = false
	player := &world.entities[world.player_id]
	player.next_command = cmd
	tm.turn_state = .RESOLVING_PLAYER
}

tm_reset :: proc(tm: ^Turn_Manager) {
	queue.clear(&tm.turn_queue)
	tm.turn_state = .WAITING_FOR_INPUT
}

tm_tick :: proc(tm: ^Turn_Manager, world: ^World) {
	switch tm.turn_state {
	case .WAITING_FOR_INPUT:
		return // player hasn't gone yet
	case .RESOLVING_PLAYER:
		player := &world.entities[world.player_id]
		acted := tm_resolve_commands(tm, world, player)
		player.next_command.type = nil

		if acted {
			queue.clear(&tm.turn_queue)
			for entity_id, &entity in world.entities {
				if entity_id != world.player_id {
					queue.enqueue(&tm.turn_queue, &entity)
				}
			}
			tm.turn_state = .RESOLVING_ENEMIES
		} else {
			if world.just_changed_floor {
				queue.clear(&tm.turn_queue)
			}
			tm.turn_state = .WAITING_FOR_INPUT
		}
	case .RESOLVING_ENEMIES:
		for tm.turn_queue.len > 0 {
			current_enemy := queue.dequeue(&tm.turn_queue)
			if current_enemy.is_alive && current_enemy.next_command.type != nil {
				tm_resolve_commands(tm, world, current_enemy)
				current_enemy.next_command.type = nil
			}
		}

		tm.turn_count += 1
		tm.turn_state = .WAITING_FOR_INPUT
		tm_gather_commands(tm, world)
	}

	world.current_difficulty = tm_current_diff(tm)
}

tm_gather_commands :: proc(tm: ^Turn_Manager, world: ^World) {
	for entity_id, &entity in world.entities {
		if entity_id != world.player_id && entity.is_alive {
			switch entity.type {
			case .PLAYER:
			case .VILLAGER:
			case .TEMPLAR:
			case .CULTIST:
				culist_think(world, &entity, &world.entities[world.player_id])
			}
		}
	}
}

tm_resolve_commands :: proc(tm: ^Turn_Manager, world: ^World, entity: ^Entity) -> bool {
	if entity.next_command.type == nil {return false}

	res := execute_command(world, entity, &entity.next_command)
	if !res.succeed {
		if res.alternative.type != nil {
			entity.next_command.type = res.alternative.type
			return tm_resolve_commands(tm, world, entity)
		}
		return false
	}
	return true
}


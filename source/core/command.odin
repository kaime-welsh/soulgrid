package core

Command_Result :: struct {
	succeed:     bool,
	alternative: Command,
}
Command_Type :: union {
	Move_Command,
	Bump_Command,
}
Command :: struct {
	type: Command_Type,
}

Move_Command :: struct {
	dx, dy: i32,
}

Bump_Command :: struct {
	target: ^Entity,
	dx, dy: i32,
}

execute_command :: proc(world: ^World, owner: ^Entity, command: ^Command) -> Command_Result {
	switch cmd in command.type {
	case Move_Command:
		if tm_get_at(&world.tile_map, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy) == .WALL {
			return Command_Result{false, {}}
		}

		target_id := world_get_entity_at(world, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy)
		if target_id != 0 {
			return Command_Result {
				false,
				{Bump_Command{&world.entities[target_id], cmd.dx, cmd.dy}},
			}
		}

		return Command_Result{true, {}}
	case Bump_Command:
	}

	return Command_Result{false, {}}
}


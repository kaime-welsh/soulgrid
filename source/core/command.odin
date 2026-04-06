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
		if grid_get_at(&world.grid, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy) == .WALL ||
		   grid_get_at(&world.grid, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy) == .EMPTY {
			return Command_Result{false, {}}
		}

		if grid_get_at(&world.grid, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy) == .EXIT &&
		   owner.type == .PLAYER {
			world_next_floor(world)
			return Command_Result{true, {}}
		}

		target_id := world_get_entity_at(world, owner.pos.x + cmd.dx, owner.pos.y + cmd.dy)
		if target_id != 0 {
			return Command_Result {
				false,
				{Bump_Command{&world.entities[target_id], cmd.dx, cmd.dy}},
			}
		}

		owner.pos += {cmd.dx, cmd.dy}
		if owner.moved != nil {
			owner.moved(owner, cmd.dx, cmd.dy)
		}
		return Command_Result{true, {}}
	case Bump_Command:
		if !cmd.target.is_alive do return Command_Result{true, {}}

		if owner.type != .PLAYER && cmd.target.type != .PLAYER {
			return Command_Result{false, {}}
		}

		if owner.type == .PLAYER {
			entity_take_damage(cmd.target, 1)
		} else {
			entity_take_damage(cmd.target, entity_current_damage(owner, world))
		}
		if owner.attacked != nil {
			owner.attacked(owner, cmd.target, cmd.dx, cmd.dy)
		}
		if !cmd.target.is_alive {
			entity_die(world, cmd.target)
		}
	}

	return Command_Result{true, {}}
}


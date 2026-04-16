class_name MoveCommand
extends Command

var _dir: Vector2i


func _init(dx: int, dy: int) -> void:
    _dir = Vector2i(dx, dy)

func execute(owner: Entity, level: LevelManager) -> Command.Result:
    var new_pos := owner.grid_position + _dir
    var cell := level.solids_tilemap.get_cell_tile_data(new_pos)

    if cell.get_custom_data("solid") == true:
        return Command.Result.new(false, null) # bumped wall
    
    if level.entities_at.has(new_pos) and level.entities_at[new_pos] != null:
        return Command.Result.new(false, BumpCommand.new(level.entities_at[new_pos])) # entity in tile, bump them

    level.entities_at[owner.grid_position] = null # clear tile where we were standing
    owner.move(new_pos.x, new_pos.y)
    owner.next_intent = null

    return Command.Result.new(false, null) # should return false to keep people from waiting
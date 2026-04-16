class_name LevelManager
extends Node2D

@export var camera: Camera2D
@export var player: PlayerController
@export var enemies: Node # TODO: Change this to an entity manager later
@export var solids_tilemap: TileMapLayer

@export var map_size: Vector2i = Vector2i(21, 11)
@export var gameSeed := "12345"

var entities_at: Dictionary[Vector2i, Entity]
var open_cells: Array[Vector2i]


func generate_floor() -> void:
	@warning_ignore("integer_division")
	camera.position = Vector2(
		float(map_size.x / 2) * Config.CELL_SIZE + 8,
		float(map_size.y / 2) * Config.CELL_SIZE + 8
	)
	
	open_cells.clear()
	while open_cells.size() <= 1:
		_generate_tiles()
		
	open_cells.shuffle()
	player.teleport(open_cells.pop_back())
	entities_at[player.grid_position] = player
				
func _ready() -> void:
	map_size = clamp(map_size, Vector2i(5, 5), Vector2i(29, 15))
	generate_floor()
	seed(int(gameSeed))
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("regen_map"):
		generate_floor()
		
func _generate_tiles() -> void:
	solids_tilemap.clear()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var cell_pos := Vector2(x, y)
			solids_tilemap.set_cell(cell_pos, 29, Vector2i(randi_range(0, 5), 0)) # default to floor

			if x == 0 or x == map_size.x - 1 or y == 0 or y == map_size.y - 1:
				solids_tilemap.set_cell(cell_pos, 20, Vector2i(randi_range(0, 6), 0))
				continue

			if randf() > 0.3:
				solids_tilemap.set_cell(cell_pos, 20, Vector2i(randi_range(0, 6), 0))
				continue

			open_cells.push_back(cell_pos)
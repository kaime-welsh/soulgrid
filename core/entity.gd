class_name Entity
extends Node2D

var next_intent: Command
var grid_position: Vector2i


func move(dx: int, dy: int) -> void:
	grid_position = Vector2i(dx, dy)

func teleport(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(grid_position) * Config.CELL_SIZE

func _process(_delta: float) -> void:
	position = lerp(position, Vector2(grid_position) * Config.CELL_SIZE, 0.4)	

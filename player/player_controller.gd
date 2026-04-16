class_name PlayerController
extends Entity

@export var _level: LevelManager


func _unhandled_input(_event: InputEvent) -> void:
	var dir: Vector2i = Vector2i.ZERO

	if Input.is_action_pressed("move_up"):
		dir = Vector2(0, -1)
	elif Input.is_action_pressed("move_down"):
		dir = Vector2(0, 1)
	elif Input.is_action_pressed("move_left"):
		dir = Vector2(-1, 0)
	elif Input.is_action_pressed("move_right"):
		dir = Vector2(1, 0)
	
	next_intent = MoveCommand.new(dir.x, dir.y)
	
func _process(_delta: float):
	if next_intent != null:
		next_intent.execute(self, _level)
	super._process(_delta)
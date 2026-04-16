class_name BumpCommand
extends Command

var _target: Entity


func _init(target: Entity) -> void:
    _target = target

func execute(_owner: Entity, _level: LevelManager):
    pass
class_name Command

class Result:
    var success: bool = false
    var alternative: Command = null

    func _init(is_successful: bool = false, has_alternative: Command = null) -> void:
        success = is_successful
        alternative = has_alternative



func execute(_owner: Entity, _level: LevelManager):
    pass
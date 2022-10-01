extends Area2D
class_name Enemy


export (bool) var ALIGN_ROTATION_IN_CLOCK = true

func _ready() -> void:
	if ALIGN_ROTATION_IN_CLOCK:
		rotation = atan2(position.y, position.x)
	pass

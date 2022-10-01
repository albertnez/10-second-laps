extends Area2D
class_name Enemy


export (bool) var ALIGN_ROTATION_IN_CLOCK = true

func _ready() -> void:
	if ALIGN_ROTATION_IN_CLOCK:
		rotation = atan2(position.y, position.x) - TAU*0.25


func move_towards_center(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * delta


# Enabling collision is delayed so we can spawn on the needle.
func _on_EnableCollisionTimer_timeout() -> void:
	monitorable = true
	monitoring = true

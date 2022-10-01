extends Area2D
class_name Player

export (float, 0, 1000.0, 10.0) var JUMPING_SPEED := 0
var _speed_y := 0.0
var _jumping := false

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and not _jumping:
		_speed_y = -JUMPING_SPEED
		_jumping = true
	
	if _jumping:
		_speed_y += gravity * delta
		position.y += _speed_y * delta
		if position.y > 0:
			_jumping = 0
			position.y = 0




func _on_Player_area_entered(area: Area2D) -> void:
	EventBus.emit_signal("collide_with_player", area)

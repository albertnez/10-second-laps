extends Area2D
class_name Player

export (float, 0, 1000.0, 10.0) var JUMPING_SPEED := 0
var _speed_y := 0.0
var _jumping := false
var _can_jump := true

func _ready() -> void:
	EventBus.connect("game_start", self, "_set_can_jump", [true])


func _set_can_jump(new_can_jump: bool) -> void:
	_can_jump = new_can_jump

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and not _jumping and _can_jump:
		_speed_y = -JUMPING_SPEED
		_jumping = true
		EventBus.emit_signal("player_jump")
	
	if _jumping:
		_speed_y += gravity * delta
		position.y += _speed_y * delta
		if position.y > 0:
			_jumping = 0
			position.y = 0




func _on_Player_area_entered(area: Area2D) -> void:
	EventBus.emit_signal("collide_with_player", area)
	_set_can_jump(false)

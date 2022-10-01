extends Node

onready var _enemy : Enemy = get_parent()

func _process(delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	_enemy.move_towards_center(100 * sin(TAU * t * 0.5) * delta)

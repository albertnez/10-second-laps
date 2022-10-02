extends Node

onready var _enemy : Enemy = get_parent()
onready var _t := 0.0

func _physics_process(delta: float) -> void:
	_t += delta
	_enemy.move_towards_center(50 * sin(TAU * _t * 0.5) * delta)

extends Node2D

onready var _needle_rotation := $"%ClockRotation"
var _lap_timer := 0.0
var _laps := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _update_timer(delta: float) -> void:
	_lap_timer += delta
	if _lap_timer > 10.0:
		_lap_timer -= 10.0
		_laps += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_timer(delta)
	_needle_rotation.rotation = TAU * (_lap_timer / 10.0)
	pass

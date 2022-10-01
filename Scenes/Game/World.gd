extends Node2D

onready var _needle_rotation := $"%ClockRotation"
onready var _player := $"%Player"
onready var _player_root_position := $"%PlayerRootPosition"
onready var _enemy_spawner := $"%EnemySpawner"
var _lap_timer := 0.0
var _laps := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("collide_with_player", self, "_on_EventBus_collide_with_player")
	EventBus.connect("collide_with_needle", self, "_on_EventBus_collide_with_needle")
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
	if Input.is_action_just_pressed("action"):
		var needle_vector : Vector2 = Vector2.UP.rotated(_needle_rotation.rotation) * _player_root_position.position.length()
		_enemy_spawner.spawn_enemy(needle_vector)
	pass


func _on_EventBus_collide_with_player(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		_player.queue_free()
	pass


func _on_EventBus_collide_with_needle(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		area.queue_free()
	pass

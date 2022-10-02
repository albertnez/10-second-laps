extends Node2D

const FadeExpandImage = preload("res://Scenes/Vfx/FadeExpandImage.tscn")

export (float, 1, 5, 0.1) var TIME_FOR_PREPARING = 1.0

onready var _needle_rotation := $"%ClockRotation"
onready var _player := $"%Player"
onready var _player_root_position := $"%PlayerRootPosition"
onready var _enemy_spawner := $"%EnemySpawner"
onready var _clock_background := $"%Background"

onready var _timer_label := $"%TimerLabel"

var _lap_timer := 0.0
var _laps := 0

var _gameover_timestamp := 0
var _preparation_tween : SceneTreeTween = null
var _preparation_time := 0.0

enum GameState {
	READY,
	PLAYING,
	GAME_OVER,
	PREPARING,
}
var _game_state = GameState.READY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.connect("collide_with_player", self, "_on_EventBus_collide_with_player")
	EventBus.connect("collide_with_needle", self, "_on_EventBus_collide_with_needle")

# seconds.fraction -> ss:mm
func _float_time_to_text(time: float) -> String:
	return ("%05.2f" % time).replace(".", ":")


func _update_timer(delta: float) -> void:
	_lap_timer += delta
	# 9.995 to avoid rounding when displaying the timer.
	if _lap_timer >= 9.995:
		_lap_timer = max(0.0, _lap_timer - 10.0)
		_laps += 1
		EventBus.emit_signal("laps_changed", _laps)
		var fade_effect := FadeExpandImage.instance()
		_clock_background.add_child(fade_effect)
	_timer_label.text = _float_time_to_text(_lap_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match _game_state:
		GameState.READY:
			if Input.is_action_just_pressed("action"):
				_start()
				
		GameState.PLAYING:
			_update_timer(delta)
			_needle_rotation.rotation = TAU * (_lap_timer / 10.0)
			if Input.is_action_just_pressed("debug_die"):
				_die()
			if Input.is_action_just_pressed("action"):
				var needle_vector : Vector2 = Vector2.UP.rotated(_needle_rotation.rotation) * _player_root_position.position.length()
				_enemy_spawner.spawn_enemy(needle_vector)
		GameState.GAME_OVER:
			# Needle moves slowly, waiting for player action.
			_needle_rotation.rotate(TAU / 20 * delta)
			_timer_label.visible = (Time.get_ticks_msec()%1500) > 750
			
			if Input.is_action_just_pressed("action") and Time.get_ticks_msec() - _gameover_timestamp > 1500:
				_prepare()
				
		GameState.PREPARING:
			_preparation_time += delta
			_timer_label.text = _float_time_to_text(_preparation_time)


func _prepare() -> void:
	_game_state = GameState.PREPARING
	_timer_label.visible = true
	_preparation_time = -TIME_FOR_PREPARING
	var target_rotation := stepify(_needle_rotation.rotation+TAU, TAU)
	_preparation_tween = create_tween()
#	_preparation_tween.parallel()
#	_preparation_tween.tween_property(self, "_preparation_time", 0)
	_preparation_tween.tween_property(_needle_rotation, "rotation", target_rotation, TIME_FOR_PREPARING)
	_preparation_tween.tween_callback(self, "_start")
	_preparation_tween.play()


func _die() -> void:
	_game_state = GameState.GAME_OVER
	_gameover_timestamp = Time.get_ticks_msec()


func _start() -> void:
	_game_state = GameState.PLAYING
	_laps = 0
	_lap_timer = 0
	EventBus.emit_signal("laps_changed", _laps)


func _on_EventBus_collide_with_player(area: Area2D) -> void:
	if area.is_in_group("Enemies") and _game_state == GameState.PLAYING:
		_die()


func _on_EventBus_collide_with_needle(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		area.queue_free()
	pass


func _on_SweepEntryDetector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		return
	area.z_index = -2


func _on_SweepEntryDetector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		return
	area.hide()

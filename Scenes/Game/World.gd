extends Node2D

const FadeExpandImage = preload("res://Scenes/Vfx/FadeExpandImage.tscn")
const TutorialEnemies = preload("res://Scenes/Game/Enemies/Tutorial.tscn")

export (float, 1, 5, 0.1) var TIME_FOR_PREPARING = 1.0

onready var _needle_rotation := $"%ClockRotation"
onready var _player := $"%Player"
onready var _player_root_position := $"%PlayerRootPosition"
onready var _enemy_spawner := $"%EnemySpawner"
onready var _clock_background := $"%Background"

onready var _restart_instructions := $"%RestartInstructions"
onready var _start_instructions := $"%StartInstructions"
onready var _tutorial_enemies := $"%TutorialEnemies"

onready var _timer_label := $"%TimerLabel"

#Audios
onready var _death_audio := $"%DeathAudio"
onready var _prepare_audio := $"%PrepareAudio"
onready var _jump_audio := $"%JumpAudio"
onready var _lap_audio := $"%LapAudio"

var _lap_timer := 0.0
var _laps := 0

var _best_laps := 0
var _best_timer := 0.0

var _gameover_timestamp := 0
var _preparation_tween : SceneTreeTween = null
var _preparation_time := 0.0
var _preparation_target_rotation := 0.0
var _needle_touched_instructions := false
var _tutorial_instantiated := false

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
	EventBus.connect("player_jump", self, "_on_EventBus_player_jump")
	# Shouldn't need to do this, but no time.
	for e in _tutorial_enemies.get_children():
		e.show()


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
		_lap_audio.play()
		var fade_effect := FadeExpandImage.instance()
		_clock_background.add_child(fade_effect)
	_timer_label.text = _float_time_to_text(_lap_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match _game_state:
		GameState.READY:
			if Input.is_action_just_pressed("action"):
				_start()
				
		GameState.PLAYING:
			_update_timer(delta)
			_needle_rotation.rotation = TAU * (_lap_timer / 10.0)
			if Input.is_action_just_pressed("debug_die") and OS.is_debug_build():
				_die()
			if Input.is_action_just_pressed("action"):
				var needle_vector : Vector2 = Vector2.UP.rotated(_needle_rotation.rotation) * _player_root_position.position.length()
				_enemy_spawner.spawn_enemy(needle_vector)
		GameState.GAME_OVER:
			# Needle moves slowly, waiting for player action.
#			_needle_rotation.rotate(TAU / 20 * delta)
			_timer_label.visible = (Time.get_ticks_msec()%1500) > 750
			
			if Input.is_action_just_pressed("action") and Time.get_ticks_msec() - _gameover_timestamp > 1500:
				_prepare()
				
		GameState.PREPARING:
			_preparation_time += delta
			_timer_label.text = _float_time_to_text(_preparation_time)
			if not _tutorial_instantiated and _is_last_lap_prepare():
				var parent = _tutorial_enemies.get_parent()
				_tutorial_enemies.queue_free()
				_tutorial_enemies = TutorialEnemies.instance()
				parent.add_child(_tutorial_enemies)
				_tutorial_instantiated = true


func _is_last_lap_prepare() -> bool:
	return _preparation_target_rotation - _needle_rotation.rotation < TAU and _game_state == GameState.PREPARING
	

func _prepare() -> void:
	_tutorial_instantiated = false
	_restart_instructions.monitorable = true
	_game_state = GameState.PREPARING
	_timer_label.visible = true
	_preparation_time = -TIME_FOR_PREPARING
	_preparation_target_rotation = stepify(_needle_rotation.rotation+TAU*1.75, TAU)
	_preparation_tween = create_tween()
#	_preparation_tween.parallel()
#	_preparation_tween.tween_property(self, "_preparation_time", 0)
	_preparation_tween.tween_property(_needle_rotation, "rotation", _preparation_target_rotation, TIME_FOR_PREPARING)
	_preparation_tween.tween_callback(self, "_start")
	_preparation_tween.play()
	
	_prepare_audio.pitch_scale = rand_range(0.9, 1.1)
	_prepare_audio.play()


func _die() -> void:
	_game_state = GameState.GAME_OVER
	_enemy_spawner.set_can_spawn(false)
	# New record!
	if _laps*10.0 + _lap_timer > _best_laps*10.0 + _best_timer:
		var new_message := str("BEST: ", _laps, " LAPS + ", _float_time_to_text(_lap_timer))
		EventBus.emit_signal("update_best_label", new_message)
		_best_laps = _laps
		_best_timer = _lap_timer
	
	_gameover_timestamp = Time.get_ticks_msec()
	_start_instructions.hide()
	_start_instructions.set_deferred("monitorable", false)
	_restart_instructions.show()
	
	_death_audio.pitch_scale = rand_range(0.9, 1.1)
	_death_audio.play()
	
	var tweener := create_tween()
	tweener.tween_property(_needle_rotation, "rotation", _needle_rotation.rotation + TAU/60, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tweener.play()
	


func _start() -> void:
	_game_state = GameState.PLAYING
	_laps = 0
	_lap_timer = 0
	EventBus.emit_signal("laps_changed", _laps)
	EventBus.emit_signal("game_start")
	_enemy_spawner.set_can_spawn(true)


func _on_EventBus_collide_with_player(area: Area2D) -> void:
	if area.is_in_group("Enemies") and _game_state == GameState.PLAYING:
		_die()


func _on_EventBus_player_jump() -> void:
	if _game_state in [GameState.READY, GameState.PLAYING]:
		_jump_audio.play()


func _restart_instructions_can_be_swept() -> bool:
	return _game_state == GameState.PREPARING and _preparation_target_rotation - _needle_rotation.rotation < TAU


func _on_SweepEntryDetector_area_entered(area: Area2D) -> void:
#	if area.is_in_group("Enemies"):
#		return
	if area.is_in_group("TutorialEnemy") and _is_last_lap_prepare():
		return

	if area.is_in_group("RestartInstructions") and not _restart_instructions_can_be_swept():
		return

	area.z_index = -2


func _on_SweepEntryDetector_area_exited(area: Area2D) -> void:
	
	if area.is_in_group("Enemies"):
		if area.is_in_group("TutorialEnemy") and _is_last_lap_prepare():
			area.show()
			
		else:
			area.queue_free()
		return

	if area.is_in_group("StartInstructions"):
		area.hide()
		area.set_deferred("monitorable", false)
		return

	if area.is_in_group("RestartInstructions"):
		if not _restart_instructions_can_be_swept():
			return
		area.set_deferred("monitorable", false)
	area.hide()
	area.z_index = 0

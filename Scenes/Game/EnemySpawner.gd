extends Node2D
class_name EnemySpawner

export (float, 0, 100, 1.0) var MINIMUM_DISTANCE_FROM_CENTER = 0

const MAX_DIST = 185
const MIN_DIST = 50
const packed_enemy := preload("res://Scenes/Game/Enemy.tscn")
const packed_row_with_floor_gap := preload("res://Scenes/Game/Enemies/RowWithFloorGap.tscn")
const packed_floating := preload("res://Scenes/Game/Enemies/FloatingEnemy.tscn")
const packed_big := preload("res://Scenes/Game/Enemies/BigEnemy.tscn")

onready var _timer := $SpawnerTimer
onready var _needle_rootation := $"%ClockRotation"

var _can_spawn := false
var _lap := 0

func _ready() -> void:
	EventBus.connect("laps_changed", self, "_set_lap")
	pass


func set_can_spawn(can_spawn: bool) -> void:
	_can_spawn = can_spawn
	_timer.start()


func _set_lap(lap: int) -> void:
	_lap = lap
	_timer.wait_time = max(0.5, 3.0 - 0.1 * lap)


func spawn_enemy(needle: Vector2) -> void:
	var enemy : Enemy = packed_enemy.instance()
	enemy.position = needle.rotated(-0.05).normalized() * rand_range(MINIMUM_DISTANCE_FROM_CENTER, needle.length())
	add_child(enemy)


func _spawn_wavy() -> void:
	var e : Enemy = packed_floating.instance()
	

func _on_SpawnerTimer_timeout() -> void:
	var enemy : Node2D = null
	var x = randf()
	var max_distance = MAX_DIST 
	if x < 0.6:
		enemy = packed_enemy.instance()
	elif x < 0.9:
		enemy = packed_floating.instance()
	else:
		enemy = packed_big.instance()
		max_distance = 170
	
	var mult := rand_range(MIN_DIST, max_distance)
	mult = max_distance
	var needle := Vector2.UP.rotated(_needle_rootation.rotation - 0.05) * mult
	enemy.position = needle
	add_child(enemy)

extends Node2D
class_name EnemySpawner

export (float, 0, 100, 1.0) var MINIMUM_DISTANCE_FROM_CENTER = 0

const MAX_DIST = 185
const MIN_DIST = 20
const packed_enemy := preload("res://Scenes/Game/Enemy.tscn")
const packed_row_with_floor_gap := preload("res://Scenes/Game/Enemies/RowWithFloorGap.tscn")

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


func spawn_enemy(needle: Vector2) -> void:
	var enemy : Enemy = packed_enemy.instance()
	enemy.position = needle.rotated(-0.05).normalized() * rand_range(MINIMUM_DISTANCE_FROM_CENTER, needle.length())
	add_child(enemy)


func _on_SpawnerTimer_timeout() -> void:
	var enemy : Enemy = packed_enemy.instance()
	var needle := Vector2.UP.rotated(_needle_rootation.rotation - 0.05) * rand_range(MIN_DIST, MAX_DIST)
	enemy.position = needle
	add_child(enemy)

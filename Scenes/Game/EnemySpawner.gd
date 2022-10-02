extends Node2D
class_name EnemySpawner

export (float, 0, 100, 1.0) var MINIMUM_DISTANCE_FROM_CENTER = 0
const enemy_packed := preload("res://Scenes/Game/Enemy.tscn")


func _ready() -> void:
	pass


func spawn_enemy(needle: Vector2) -> void:
	var enemy : Enemy = enemy_packed.instance()
	enemy.position = needle.rotated(-0.05).normalized() * rand_range(MINIMUM_DISTANCE_FROM_CENTER, needle.length())
	add_child(enemy)

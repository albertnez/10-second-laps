extends Area2D


func _ready() -> void:
	pass


func _on_Needle_area_entered(area: Area2D) -> void:
	EventBus.emit_signal("collide_with_needle", area)

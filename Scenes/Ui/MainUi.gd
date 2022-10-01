extends Control

onready var _laps_label := $"%LapsLabel"

func _ready() -> void:
	EventBus.connect("laps_changed", self, "_on_EventBus_laps_changed")


func _on_EventBus_laps_changed(num_laps: int) -> void:
	_laps_label.text = str("Laps: ", num_laps)

extends Control

onready var _laps_label := $"%LapsLabel"
onready var _volume_slide := $"%VolumeSlide"
onready var _best_score_label := $"%BestScoreLabel"

func _ready() -> void:
	EventBus.connect("laps_changed", self, "_on_EventBus_laps_changed")
	EventBus.connect("update_best_label", _best_score_label, "set_text")


func _on_EventBus_laps_changed(num_laps: int) -> void:
	_laps_label.text = str(num_laps)


func _on_VolumeSlide_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear2db(value/_volume_slide.max_value))
	pass # Replace with function body.

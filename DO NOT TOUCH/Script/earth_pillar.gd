extends Node3D

@export var grow_time := 0.12


func _ready() -> void:
	scale.y = 0.001
	create_tween().tween_property(self, "scale:y", 1.0, grow_time)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

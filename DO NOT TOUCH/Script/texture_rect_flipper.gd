extends TextureRect

@export var flip_interval: float = 1.0

func _ready() -> void:
	while true:
		await get_tree().create_timer(flip_interval).timeout
		flip_h = !flip_h

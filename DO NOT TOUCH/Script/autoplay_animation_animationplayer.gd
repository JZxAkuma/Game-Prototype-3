extends AnimationPlayer

@export var animation_to_play: String = "RESET"

func _ready() -> void:
	play(animation_to_play)

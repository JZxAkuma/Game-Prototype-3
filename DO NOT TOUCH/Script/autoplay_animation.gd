extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var animation_name: StringName = &"RESET"

func _ready() -> void:
	animation_player.play(animation_name)

func _process(_delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play(animation_name)

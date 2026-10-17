extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 120

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

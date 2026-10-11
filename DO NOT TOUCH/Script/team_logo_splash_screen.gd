extends CanvasLayer

func _finish() -> void:
	SceneManager.goto_scene(preload("res://DO NOT TOUCH/Scene/main_menu.tscn"))

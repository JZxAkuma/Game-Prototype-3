extends Node3D

const lobby := preload("res://DO NOT TOUCH/Scene/lobby.tscn")

func _on_start_pressed() -> void:
	SceneManager.goto_scene(lobby)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Playground/world.tscn")

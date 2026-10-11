extends Node3D

const lobby := preload("res://DO NOT TOUCH/Scene/lobby.tscn")

func _on_start_pressed() -> void:
	SceneManager.goto_scene(lobby)

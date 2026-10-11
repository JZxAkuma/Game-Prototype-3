extends Node3D

const main_menu := preload("res://DO NOT TOUCH/Scene/main_menu.tscn")
const lobby := preload("res://DO NOT TOUCH/Scene/lobby.tscn")
const board := preload("res://DO NOT TOUCH/Scene/board.tscn")

var current : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.register_container(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.

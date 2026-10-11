extends Node

class PlayerData:
	var slot := 0
	var character := 0
	var coins:= 10
	var stars := 0
	var space_index := 0

var players: Array[PlayerData] = []
var board_seed := 0
var space_types: Array[int] = []
var turn := 0

var current_player := 0

const character_scenes : Array[PackedScene] = [
	preload("res://DO NOT TOUCH/character/character_1.tscn"),
	preload("res://DO NOT TOUCH/character/character_2.tscn"),
	preload("res://DO NOT TOUCH/character/character_3.tscn"),
	preload("res://DO NOT TOUCH/character/character_4.tscn")
]

func _new_game(slots:Array[int]) -> void:
	players.clear()
	for slot in slots:
		var p := PlayerData.new()
		p.slot = slot
		p.character = slot
		players.append(p)

func _next_player() -> void:
	current_player += 1
	if current_player >= players.size():
		current_player = 0
		turn += 1

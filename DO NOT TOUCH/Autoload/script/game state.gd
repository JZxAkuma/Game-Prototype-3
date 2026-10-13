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

#var current_minigame: MINI_GAME
#
#const minigames := [
	#preload("res://DO NOT TOUCH/Resources/minigames/sumo.tres")
#]

# game_state.gd
var current_minigame: MINI_GAME

const MINIGAME_PATHS: Array[String] = [
	"res://DO NOT TOUCH/Resources/minigames/sumo.tres",
]

func pick_minigame() -> MINI_GAME:
	var path: String = MINIGAME_PATHS.pick_random()
	current_minigame = load(path) as MINI_GAME
	return current_minigame

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

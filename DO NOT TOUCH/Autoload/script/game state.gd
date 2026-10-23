extends Node

class PlayerData:
	var slot := 0
	var character := 0
	var coins:= 10
	var medal := 0
	var space_index := 0

signal data_changed

var players: Array[PlayerData] = []
var board_seed := 0
var space_types: Array[int] = []
var turn := 0

var _bag: Array[String] = []
var _last_path := ""

var current_player := 0

var intro_played := false

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
	"res://DO NOT TOUCH/Resources/minigames/flappy.tres",
	"res://DO NOT TOUCH/Resources/minigames/button mash.tres",
	"res://DO NOT TOUCH/Resources/minigames/cold_potato.tres",
	"res://DO NOT TOUCH/Resources/minigames/dodgeball.tres"
]

func pick_minigame() -> MINI_GAME:
	if _bag.is_empty():
		_refill_bag()
	var path: String = _bag.pop_back()
	_last_path = path
	current_minigame = load(path) as MINI_GAME
	return current_minigame

func _new_game(slots: Array[int]) -> void:
	players.clear()
	for slot in slots:
		var p := PlayerData.new()
		p.slot = slot
		p.character = slot
		players.append(p)

	board_seed = randi()
	space_types.clear()
	turn = 0
	current_player = 0
	intro_played = false
	_bag.clear()
	_last_path = ""

func _next_player() -> void:
	current_player += 1
	if current_player >= players.size():
		current_player = 0
		turn += 1
	data_changed.emit()

func _add_coins(p: PlayerData, amount: int) -> void:
	p.coins = maxi(0, p.coins + amount)
	data_changed.emit()

func _add_medal(p: PlayerData, amount: int) -> void:
	p.medal = maxi(0, p.medal + amount)
	data_changed.emit()

func _get_all_minigames() -> Array[MINI_GAME]:
	var list: Array[MINI_GAME] = []
	for path in MINIGAME_PATHS:
		list.append(load(path) as MINI_GAME)
	return list

func pick_minigame_by_id(id: String) -> MINI_GAME:
	for path in MINIGAME_PATHS:
		if path.get_file().get_basename() == id:
			current_minigame = load(path) as MINI_GAME
			return current_minigame
	return null

func _refill_bag() -> void:
	_bag.assign(MINIGAME_PATHS)
	_bag.shuffle()
	if _bag.size() > 1 and _bag.back() == _last_path:
		var swap_i := randi() % (_bag.size() - 1)
		var tmp = _bag[swap_i]
		_bag[swap_i] = _bag.back()
		_bag[_bag.size() - 1] = tmp

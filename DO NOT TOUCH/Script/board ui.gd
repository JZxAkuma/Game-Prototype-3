extends Control

const CARD := preload("res://DO NOT TOUCH/Scene/player_hud_card.tscn")

@onready var box: HBoxContainer = $HBoxContainer
@onready var current_turn_label: Label = $"Current turn"

var cards := {}


func _ready() -> void:
	for p in GameState.players:
		var card: PlayerHudCard = CARD.instantiate()
		box.add_child(card)
		card.setup(p)
		cards[p.slot] = card
	GameState.data_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var current := GameState.players[GameState.current_player]
	current_turn_label.text = "Turn: P%d (round %d)" % [current.slot + 1, GameState.turn + 1]
	for p in GameState.players:
		cards[p.slot].refresh(p)

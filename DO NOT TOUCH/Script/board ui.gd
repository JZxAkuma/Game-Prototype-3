extends Control

@onready var box: HBoxContainer = $HBoxContainer
@onready var current_turn_label: Label = $"Current turn"

var labels := {}   # slot -> Label


func _ready() -> void:
	for p in GameState.players:
		var l := Label.new()
		box.add_child(l)
		labels[p.slot] = l
	GameState.data_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var current := GameState.players[GameState.current_player]
	current_turn_label.text = "Turn: P%d (round %d)" % [current.slot + 1, GameState.turn + 1]

	for p in GameState.players:
		var marker := "> " if p == current else ""
		labels[p.slot].text = "| %sP%d  coins %d medals %d |" % [
			marker, p.slot + 1, p.coins, p.medal
		]

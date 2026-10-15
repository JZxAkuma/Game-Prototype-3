extends CanvasLayer

signal finished

@export var laps := 3
@export var start_delay := 0.06
@export var end_delay := 0.35

@onready var box: HBoxContainer = $Control/HBoxContainer

var cards: Array[PanelContainer] = []


func _play(list: Array, winner: MINI_GAME) -> void:
	for mg in list:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(220, 120)
		var l := Label.new()
		l.text = mg.mini_game_name
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card.add_child(l)
		box.add_child(card)
		cards.append(card)
		_set_lit(card, false)

	var n := cards.size()
	var winner_index := list.find(winner)
	var total_steps := n * laps + winner_index
	var current := -1

	for step in total_steps + 1:
		if current >= 0:
			_set_lit(cards[current], false)
		current = step % n
		_set_lit(cards[current], true)

		var t := float(step) / float(total_steps)
		await get_tree().create_timer(lerpf(start_delay, end_delay, t * t)).timeout
		if not is_inside_tree():
			return

	await get_tree().create_timer(1.0).timeout
	finished.emit()

func _set_lit(card: Control, lit: bool) -> void:
	card.modulate = Color.WHITE if lit else Color(0.5, 0.5, 0.5)

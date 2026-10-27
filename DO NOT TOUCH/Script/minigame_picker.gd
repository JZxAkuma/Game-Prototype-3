extends CanvasLayer

signal finished

@export var repeats := 8
@export var spin_time := 4.0
@export var card_size := Vector2(220, 120)
@export var gap := 16
@export var normal_style: StyleBox
@export var lit_style: StyleBox

@onready var window: Control = $Control/Control
@onready var box: HBoxContainer = $Control/Control/HBoxContainer

var cards: Array[PanelContainer] = []
var lit_index := -1
var step := 0.0
var center := 0.0


func _play(list: Array, winner: MINI_GAME) -> void:
	var n := list.size()
	if n == 0:
		finished.emit()
		return

	box.add_theme_constant_override("separation", gap)
	for r in repeats:
		for mg in list:
			cards.append(_make_card(mg))

	var winner_index := 0
	for i in n:
		if list[i] == winner or list[i].resource_path == winner.resource_path:
			winner_index = i
			break

	await get_tree().process_frame
	if not is_inside_tree():
		return

	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return

	center = window.size.x * 0.5
	box.position.y = (window.size.y - card_size.y) * 0.5

	var first: Control = cards[0]
	var start_x := center - (first.position.x + first.size.x * 0.5)

	var target: Control = cards[(repeats - 2) * n + winner_index]
	var end_x := center - (target.position.x + target.size.x * 0.5)

	box.position.x = start_x
	_light(start_x)

	var tw := create_tween()
	tw.tween_method(_scroll, start_x, end_x, spin_time)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tw.finished
	if not is_inside_tree():
		return

	_light(end_x)
	await get_tree().create_timer(1.0).timeout
	finished.emit()


func _scroll(x: float) -> void:
	box.position.x = x
	_light(x)


func _light(x: float) -> void:
	var mx := center - x
	var idx := 0
	var best := INF
	for i in cards.size():
		var c: Control = cards[i]
		var d := absf(c.position.x + c.size.x * 0.5 - mx)
		if d < best:
			best = d
			idx = i
	if idx == lit_index:
		return
	if lit_index >= 0:
		_set_lit(cards[lit_index], false)
	lit_index = idx
	_set_lit(cards[idx], true)


func _make_card(mg: MINI_GAME) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = card_size
	var l := Label.new()
	l.text = mg.mini_game_name
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(l)
	box.add_child(card)
	_set_lit(card, false)
	return card


func _set_lit(card: Control, lit: bool) -> void:
	var s := lit_style if lit else normal_style
	if s:
		card.add_theme_stylebox_override("panel", s)
	else:
		card.modulate = Color.WHITE if lit else Color(0.5, 0.5, 0.5)

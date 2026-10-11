extends Node3D

const board := preload("res://DO NOT TOUCH/Scene/board.tscn")

@export var card_scene : PackedScene
@export var characters : Array[CharacterData]
@export var min_players := 1

@onready var prompt: Label = $CanvasLayer/Control/prompt
@onready var cards_box: HBoxContainer = $CanvasLayer/Control/cards_box

var cards := {}

func _ready() -> void:
	PlayerInput._reset()
	PlayerInput.registration_changed.connect(_refresh)
	_refresh()

func _input(event: InputEvent) -> void:
	if SceneManager.busy:
		return

	# Debug: any key press = keyboard plays all 4 slots
	if event is InputEventKey and event.pressed and not event.echo:
		PlayerInput._register_keyboard_for_all()
		_finish()
		return

	# Everything below is controller-only
	if not (event is InputEventJoypadButton and event.pressed):
		return

	if event.is_action_pressed(&"a"):
		PlayerInput._register_joypad(event.device)
	elif event.is_action_pressed(&"b"):
		PlayerInput._unregister_joypad(event.device)
	elif event.is_action_pressed(&"start"):
		if _registered_count() >= min_players:
			_finish()


func _registered_count() -> int:
	var n := 0
	for s in PlayerInput.max_player:
		if PlayerInput._is_slot_registered(s):
			n += 1
	return n

func _refresh() -> void:
	for slot in PlayerInput.max_player:
		var registered := PlayerInput._is_slot_registered(slot)
		if registered and not cards.has(slot):
			var card := card_scene.instantiate()
			cards_box.add_child(card)
			card._setup(slot,characters[slot])
			cards[slot] = card
		elif not registered and cards.has(slot):
			cards[slot].queue_free()
			cards.erase(slot)
	
	var order := cards.keys()
	order.sort()
	for slot in order:
		cards_box.move_child(cards[slot], -1)
	
	prompt.visible = cards.is_empty()
	
func _finish() -> void:
	set_process_input(false)
	PlayerInput._build_action()
	
	var slots: Array[int] = []
	for s in PlayerInput.max_player:
		if PlayerInput._is_slot_registered(s):
			slots.append(s)
	
	GameState._new_game(slots)
	SceneManager.goto_scene(board)
	
	
	
	
	

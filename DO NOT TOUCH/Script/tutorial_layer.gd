extends CanvasLayer

signal all_ready

const READY_CARD := preload("res://DO NOT TOUCH/Scene/ready_up_card.tscn")

@export var play_cam: Camera3D

@onready var title_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/title label"
@onready var goal_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/goal label"
@onready var controls_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/controls label"
@onready var tutorial_card_container: HBoxContainer = $"Control/VBoxContainer/tutorial card container"
@onready var camera_3d: Camera3D = $Control/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Camera3D

var ready_slots := {}
var cards := {}
var total := 0


func _ready() -> void:
	_sync_camera()
	set_process(false)


func _setup(data: MINI_GAME, players: Array) -> void:
	title_label.text = data.mini_game_name
	goal_label.text = data.goal
	controls_label.text = data.controls

	for c in tutorial_card_container.get_children():
		c.queue_free()
	cards.clear()
	ready_slots.clear()

	total = players.size()
	for p in players:
		var card: ReadyUpCard = READY_CARD.instantiate()
		tutorial_card_container.add_child(card)
		card.setup(p.slot)
		cards[p.slot] = card

	_sync_camera()


func _begin() -> void:
	set_process(true)


func _is_everyone_ready() -> bool:
	return total > 0 and ready_slots.size() >= total


func _process(_delta: float) -> void:
	_sync_camera()

	for slot in cards:
		if ready_slots.has(slot):
			continue
		if Input.is_action_pressed(PlayerInput._act(slot, &"lb")) \
				and Input.is_action_pressed(PlayerInput._act(slot, &"rb")):
			ready_slots[slot] = true
			cards[slot].set_ready(true)

	if _is_everyone_ready():
		set_process(false)
		all_ready.emit()


func _sync_camera() -> void:
	if play_cam and camera_3d:
		camera_3d.global_transform = play_cam.global_transform

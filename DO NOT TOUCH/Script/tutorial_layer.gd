extends CanvasLayer

signal all_ready

@onready var title_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/title label"
@onready var goal_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/goal label"
@onready var controls_label: Label = $"Control/VBoxContainer/HBoxContainer/VBoxContainer/controls label"
@onready var tutorial_card_container: HBoxContainer = $"Control/VBoxContainer/tutorial card container"
@onready var camera_3d: Camera3D = $Control/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Camera3D


@export var play_cam : Camera3D


var ready_slots := {}
var labels := {}
var total := 0

func _ready() -> void:
	camera_3d.global_transform = play_cam.global_transform
	set_process(false) 

func _setup(data:MINI_GAME, players:Array) -> void:
	title_label.text = data.mini_game_name
	goal_label.text = data.goal
	controls_label.text = data.controls
	
	total = players.size()
	for p in players:
		var panel := PanelContainer.new()
		var l := Label.new()
		l.text = "P%d\nHold LB + RB" % (p.slot + 1)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(l)
		tutorial_card_container.add_child(panel)
		labels[p.slot] = l

func _is_everyone_ready() -> bool:
	return total > 0 and ready_slots.size() >= total

func _process(delta: float) -> void:
	for slot in labels:
		if ready_slots.has(slot):
			continue
		if Input.is_action_pressed(PlayerInput._act(slot, &"lb")) \
			 and Input.is_action_pressed(PlayerInput._act(slot, &"rb")):
			ready_slots[slot] = true
			labels[slot].text = "P%d\nREADY!" % (slot + 1)
	if _is_everyone_ready():
		self.hide()
		set_process(false)
		all_ready.emit()


func _begin() -> void:
	set_process(true)

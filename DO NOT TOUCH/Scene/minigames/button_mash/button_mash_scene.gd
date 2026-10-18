extends MiniGameBase

const round_time := 5

@export var pillar_step := Vector3(0, 0, -1.5)
@export var play_cam: Camera3D
@export var cam_pan_time := 1.5

var dirt_pillar := preload("res://DO NOT TOUCH/Scene/earth_pillar.tscn")

@onready var lane_1: Marker3D = $"Game scene/pillar_lane/lane1"
@onready var lane_2: Marker3D = $"Game scene/pillar_lane/lane2"
@onready var lane_3: Marker3D = $"Game scene/pillar_lane/lane3"
@onready var lane_4: Marker3D = $"Game scene/pillar_lane/lane4"

@onready var timer_label: Label = $"Game layer/Control/Label"

var lanes: Array[Marker3D] = []
var pillars: Array[Node] = []
var round_id := 0


func _ready() -> void:
	lanes = [lane_1, lane_2, lane_3, lane_4]
	timer_label.hide()
	tutorial_ui.all_ready.connect(_clear_pillars)
	super()


func _spawn_characters() -> void:
	super()
	for c in chars.values():
		c.state_changed.connect(_on_state_changed)


func _on_state_changed(_c: PlayerCharacter, s: CharacterState) -> void:
	if s.has_signal(&"mashed"):
		s.connect(&"mashed", _on_mashed)


func _on_mashed(c: PlayerCharacter) -> void:
	if state == State.results or c.slot >= lanes.size():
		return
	var lane := lanes[c.slot]
	var index := c.score - 1
	var p: Node3D = dirt_pillar.instantiate()
	lane.get_parent().add_child(p)
	p.global_position = lane.global_position + lane.global_basis * (pillar_step * index)
	pillars.append(p)


func _clear_pillars() -> void:
	for p in pillars:
		if is_instance_valid(p):
			p.queue_free()
	pillars.clear()


func _start_round(practice: bool) -> void:
	super(practice)
	round_id += 1
	_clear_pillars()
	timer_label.hide()
	if practice:
		return
	_run_timer(round_id)


func _run_timer(id: int) -> void:
	var end_ms := Time.get_ticks_msec() + round_time * 1000
	var left := round_time
	timer_label.text = str(left)
	timer_label.show()

	while left > 0:
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree() or id != round_id or state != State.play:
			return
		left = maxi(ceili((end_ms - Time.get_ticks_msec()) / 1000.0), 0)
		timer_label.text = str(left)

	timer_label.hide()
	_finish_round()


func _finish_round() -> void:
	var best := 0
	var winner := -1
	var tied := false
	for c in chars.values():
		if c.score > best:
			best = c.score
			winner = c.slot
			tied = false
		elif c.score == best and best > 0:
			tied = true

	_pan_to_furthest(winner, best)
	round_over.emit(-1 if tied else winner)


func _pan_to_furthest(slot: int, count: int) -> void:
	if play_cam == null or slot < 0 or count < 2 or slot >= lanes.size():
		return
	var lane := lanes[slot]
	var offset := lane.global_basis * (pillar_step * (count - 1))
	var tw := create_tween()
	tw.tween_property(play_cam, "global_position", play_cam.global_position + offset, cam_pan_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

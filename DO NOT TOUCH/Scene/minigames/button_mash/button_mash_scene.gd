extends MiniGameBase

const round_time := 10.0

@export var pillar_step := Vector3(0, 0, -1.5)

var dirt_pillar := preload("res://DO NOT TOUCH/Scene/earth_pillar.tscn")

@onready var lane_1: Marker3D = $"Game scene/pillar_lane/lane1"
@onready var lane_2: Marker3D = $"Game scene/pillar_lane/lane2"
@onready var lane_3: Marker3D = $"Game scene/pillar_lane/lane3"
@onready var lane_4: Marker3D = $"Game scene/pillar_lane/lane4"

var lanes: Array[Marker3D] = []
var pillars: Array[Node] = []
var round_id := 0


func _ready() -> void:
	lanes = [lane_1, lane_2, lane_3, lane_4]
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
	if practice:
		return
	var id := round_id
	await get_tree().create_timer(round_time).timeout
	if not is_inside_tree() or id != round_id or state != State.play:
		return
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
	round_over.emit(-1 if tied else winner)

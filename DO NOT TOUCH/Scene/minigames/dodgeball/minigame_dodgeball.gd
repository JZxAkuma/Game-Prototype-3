extends MiniGameBase

const BALL := preload("res://DO NOT TOUCH/Scene/dodgeball_ball.tscn")

@export var split_on_x := true
@export var half_size := 100.0
@export var middle_gap := 0.5
@export var throw_speed := 18.0
@export var ball_spawns: Array[Marker3D]

var alive: Array = []
var balls: Array[DodgeBall] = []
var held := {}


func _ready() -> void:
	tutorial_ui.all_ready.connect(_reset_balls)
	super()


func _spawn_characters() -> void:
	super()
	for c in chars.values():
		c.state_changed.connect(_on_state_changed)


func _on_state_changed(c: PlayerCharacter, s: CharacterState) -> void:
	if s.has_method(&"set_bounds"):
		var axis := 0 if split_on_x else 2
		if c.slot % 2 == 0:
			s.set_bounds(axis, -half_size, -middle_gap)
		else:
			s.set_bounds(axis, middle_gap, half_size)
	if s.has_signal(&"threw"):
		s.connect(&"threw", _on_threw)

func _reset_balls() -> void:
	for b in balls:
		if is_instance_valid(b):
			b.queue_free()
	balls.clear()
	held.clear()

	for m in ball_spawns:
		var b: DodgeBall = BALL.instantiate()
		players_root.get_parent().add_child(b)
		b.global_position = m.global_position
		b.hit_character.connect(_on_ball_hit, CONNECT_DEFERRED)
		b.pick_requested.connect(_on_pick_requested)
		balls.append(b)


func _on_pick_requested(b: DodgeBall, c: PlayerCharacter) -> void:
	if state == State.results or b.holder != null:
		return
	if not alive.has(c.slot) or held.has(c.slot):
		return
	b.holder = c
	held[c.slot] = b


func _on_threw(c: PlayerCharacter, dir: Vector3) -> void:
	if state == State.results or not held.has(c.slot):
		return
	var b: DodgeBall = held[c.slot]
	held.erase(c.slot)
	c.play_anim(&"throw")
	b.global_position = c.global_position + dir * 1.0 + Vector3.UP * 1.0
	b.release(dir * throw_speed, c.slot % 2)


func _on_ball_hit(_ball: DodgeBall, c: PlayerCharacter) -> void:
	match state:
		State.tutorial:
			c.play_anim(&"hit")
		State.play:
			_eliminate(c)

func _eliminate(c: PlayerCharacter) -> void:
	if not alive.has(c.slot):
		return
	alive.erase(c.slot)

	if held.has(c.slot):
		held[c.slot].drop()
		held.erase(c.slot)

	c.lock()
	c.hide()
	c.process_mode = Node.PROCESS_MODE_DISABLED

	var teams_left: Array = []
	for s in alive:
		if not teams_left.has(s % 2):
			teams_left.append(s % 2)
	if teams_left.size() > 1:
		return

	if teams_left.is_empty():
		round_over.emit(-1)
		return
	var team: int = teams_left[0]
	extra_winners = chars.keys().filter(func(s): return s % 2 == team)
	round_over.emit(extra_winners[0])

func _start_round(practice: bool) -> void:
	super(practice)
	_reset_balls()
	extra_winners.clear()
	alive = chars.keys()

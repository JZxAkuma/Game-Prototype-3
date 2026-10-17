extends MiniGameBase

@export var play_cam: Camera3D
@export var round_time := 30

@export_group("Camera")
@export var follow_threshold := 3.0
@export var gap_threshold := 4.0
@export var zoom_per_unit := 1.0
@export var max_pull_back := 20.0
@export var cam_smooth := 3.0

@onready var timer_label: Label = $"Game layer/Control/Label"

@onready var obstacle_spawner: Node3D = $"Game scene/obstacle spawner"
@onready var point_1: Marker3D = $"Game scene/obstacle spawner/point1"
@onready var point_2: Marker3D = $"Game scene/obstacle spawner/point2"

var obstacle = preload("res://DO NOT TOUCH/Scene/flappy_obstacle.tscn")

@export_group("Obstacles")
@export var start_interval := 2.0
@export var end_interval := 0.5

@export var spawner_offset_y := 20.0

var spawner_default_y := 0.0

var spawned: Array[Node] = []
var round_id := 0
var cam_default_pos := Vector3.ZERO
var cam_back := Vector3.BACK


func _ready() -> void:
	cam_default_pos = play_cam.global_position
	cam_back = play_cam.global_basis.z
	spawner_default_y = obstacle_spawner.global_position.y
	super()


func _process(delta: float) -> void:
	_update_camera(delta)
	_update_spawner()


func _update_camera(delta: float) -> void:
	if play_cam == null or chars.is_empty():
		return

	var top := -INF
	var bottom := INF
	for c in chars.values():
		if is_instance_valid(c) and c.visible:
			top = maxf(top, c.global_position.y)
			bottom = minf(bottom, c.global_position.y)
	if top == -INF:
		return

	var goal := cam_default_pos

	if top > cam_default_pos.y + follow_threshold:
		goal.y = maxf((top + bottom) * 0.5, cam_default_pos.y)

	var gap_excess := maxf((top - bottom) - gap_threshold, 0.0)
	var pull := minf(gap_excess * zoom_per_unit, max_pull_back)
	goal += cam_back * pull

	var t := 1.0 - exp(-cam_smooth * delta)
	play_cam.global_position = play_cam.global_position.lerp(goal, t)


func _start_round(practice: bool) -> void:
	super(practice)
	round_id += 1
	_clear_obstacles()
	_spawn_loop(round_id)
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
	var best := -INF
	var winner := -1
	var tied := false
	for c in chars.values():
		var height: float = c.global_position.y
		c.score = roundi(height * 100.0)
		if height > best + 0.01:
			best = height
			winner = c.slot
			tied = false
		elif absf(height - best) <= 0.01:
			tied = true
	round_over.emit(-1 if tied else winner)

func _spawn_loop(id: int) -> void:
	var start_ms := Time.get_ticks_msec()
	while true:
		var elapsed := (Time.get_ticks_msec() - start_ms) / 1000.0
		var t := clampf(elapsed / round_time, 0.0, 1.0)
		var wait := lerpf(start_interval, end_interval, t)
		await get_tree().create_timer(wait).timeout
		if not is_inside_tree() or id != round_id or state != State.play:
			return
		_spawn_obstacle()


func _spawn_obstacle() -> void:
	var o: Node3D = obstacle.instantiate()
	obstacle_spawner.get_parent().add_child(o)
	o.global_position = point_1.global_position.lerp(point_2.global_position, randf())
	spawned.append(o)


func _clear_obstacles() -> void:
	for o in spawned:
		if is_instance_valid(o):
			o.queue_free()
	spawned.clear()

func _update_spawner() -> void:
	if chars.is_empty():
		return

	var top := -INF
	for c in chars.values():
		if is_instance_valid(c) and c.visible:
			top = maxf(top, c.global_position.y)
	if top == -INF:
		return

	var pos := obstacle_spawner.global_position
	pos.y = maxf(top + spawner_offset_y, spawner_default_y)
	obstacle_spawner.global_position = pos

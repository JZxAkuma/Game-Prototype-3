extends MiniGameBase

@export var play_cam: Camera3D
@export var round_time := 30

@export_group("Camera")
@export var follow_threshold := 3.0
@export var gap_threshold := 4.0
@export var zoom_per_unit := 1.0
@export var max_pull_back := 15.0
@export var cam_smooth := 3.0

@onready var timer_label: Label = $"Game layer/Control/Label"

var round_id := 0
var cam_default_pos := Vector3.ZERO
var cam_back := Vector3.BACK


func _ready() -> void:
	cam_default_pos = play_cam.global_position
	cam_back = play_cam.global_basis.z
	super()


func _process(delta: float) -> void:
	_update_camera(delta)


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

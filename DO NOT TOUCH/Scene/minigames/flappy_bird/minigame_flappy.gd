extends MiniGameBase

@export var play_cam: Camera3D
@export var round_time := 120

@onready var timer_label: Label = $"Game layer/Control/Label"

var round_id := 0


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
	var best := -1
	var winner := -1
	var tied := false
	for c in chars.values():
		if c.score > best:
			best = c.score
			winner = c.slot
			tied = false
		elif c.score == best:
			tied = true
	round_over.emit(-1 if tied else winner)

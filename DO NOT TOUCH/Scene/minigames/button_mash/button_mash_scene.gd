extends MiniGameBase

const round_time := 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_round(_practice: bool) -> void:
	super(_practice)
	if _practice:
		return
	await get_tree().create_timer(round_time).timeout
	if not is_inside_tree() or state != State.play:
		return
	var best := 1
	var winner := -1
	for c in chars.values():
		if c.score > best:
			best = c.score
			winner = c.slot
	round_over.emit(winner)

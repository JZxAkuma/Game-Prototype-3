extends MiniGameBase

const round_time := 30

@export var medal: Medal
@export var holder_knockback := 6.0
@export var steal_lock_time := 0.5 
@export var holding_is_good := true

@onready var timer_label: Label = $"Game layer/Control/Label"

var holder_slot := -1
var steal_lock := 0.0
var hold_time := {}
var claims: Array = []
var round_id := 0


func _ready() -> void:
	timer_label.hide()
	medal.touched.connect(func(c): _queue_claim(c, null))
	tutorial_ui.all_ready.connect(_reset_medal)
	super()


func _spawn_characters() -> void:
	super()
	for c in chars.values():
		c.state_changed.connect(_on_state_changed)


func _on_state_changed(_c: PlayerCharacter, s: CharacterState) -> void:
	if s.has_signal(&"bumped"):
		s.connect(&"bumped", _on_bumped)
	if s.has_signal(&"fell_off"):
		s.connect(&"fell_off", _on_fell, CONNECT_DEFERRED)


func _on_fell(c: PlayerCharacter) -> void:
	if state != State.results:
		_respawn_one(c)
		
func _on_bumped(a: PlayerCharacter, b: PlayerCharacter) -> void:
	if a.slot == holder_slot and b.slot != holder_slot:
		_queue_claim(b, a)


func _queue_claim(taker: PlayerCharacter, from) -> void:
	claims.append({"taker": taker, "from": from})
	if claims.size() == 1:
		_resolve_claims.call_deferred() 


func _resolve_claims() -> void:
	print("resolving claims: ", claims.size(), " holder: ", holder_slot, " state: ", state)
	var valid: Array = []
	for cl in claims:
		var from: PlayerCharacter = cl.from
		var ok := false
		if from == null:
			ok = holder_slot == -1 
		else:
			ok = holder_slot == from.slot and steal_lock <= 0.0
		if ok and cl.taker.slot != holder_slot:
			valid.append(cl)
	claims.clear()

	if valid.is_empty() or state == State.results:
		return
	var win: Dictionary = valid[randi() % valid.size()]
	_give_medal(win.taker, win.from)


func _give_medal(taker: PlayerCharacter, from) -> void:
	holder_slot = taker.slot
	steal_lock = steal_lock_time
	medal.attach_to(taker)
	if from and from.state and from.state.has_method(&"push_from"):
		from.state.push_from(taker.global_position, holder_knockback)


func _process(delta: float) -> void:
	steal_lock = maxf(steal_lock - delta, 0.0)
	if state == State.play and holder_slot != -1:
		hold_time[holder_slot] = hold_time.get(holder_slot, 0.0) + delta
		chars[holder_slot].score = roundi(hold_time[holder_slot] * 100.0)


func _reset_medal() -> void:
	holder_slot = -1
	steal_lock = 0.0
	claims.clear()
	medal.reset()


func _start_round(practice: bool) -> void:
	super(practice)
	round_id += 1
	hold_time.clear()
	_reset_medal()
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
		var t: float = hold_time.get(c.slot, 0.0)
		var value := t if holding_is_good else -t
		if value > best + 0.05:
			best = value
			winner = c.slot
			tied = false
		elif absf(value - best) <= 0.05:
			tied = true
	round_over.emit(-1 if tied else winner)

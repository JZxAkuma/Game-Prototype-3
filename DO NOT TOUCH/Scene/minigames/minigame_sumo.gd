extends MiniGameBase

var alive: Array = []


func _spawn_characters() -> void:
	super()
	for c in chars.values():
		c.state_changed.connect(_on_state_changed)


func _on_state_changed(_c: PlayerCharacter, s: CharacterState) -> void:
	# Only sumo states have this signal
	if s.has_signal(&"fell_off"):
		s.connect(&"fell_off", _on_fell, CONNECT_DEFERRED)


func _on_fell(c: PlayerCharacter) -> void:
	match state:
		State.tutorial:
			_respawn_one(c)
		State.play:
			_eliminate(c)


func _eliminate(c: PlayerCharacter) -> void:
	if not alive.has(c.slot):
		return
	alive.erase(c.slot)
	c.set_mode(PlayerCharacter.Mode.LOCKED)
	c.hide()
	c.process_mode = Node.PROCESS_MODE_DISABLED
	if alive.size() == 1:
		round_over.emit(alive[0])
	elif alive.is_empty():
		round_over.emit(-1)


func _start_round(practice: bool) -> void:
	super(practice)
	alive = chars.keys()

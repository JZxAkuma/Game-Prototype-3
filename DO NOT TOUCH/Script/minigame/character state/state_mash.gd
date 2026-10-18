extends CharacterState

signal mashed(character: PlayerCharacter)


func _enter() -> void:
	character.score = 0
	character.play_anim(&"idle")


func _handle_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(PlayerInput._act(character.slot, &"a")):
		character.score += 1
		character.play_anim(&"mash")
		mashed.emit(character)

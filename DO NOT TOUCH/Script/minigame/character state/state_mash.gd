extends CharacterState

func _enter() -> void:
	character.score = 0
	character.play_anim(&"idle")

func _handle_input(_event: InputEvent) -> void:
	if _event.is_action(PlayerInput._act(character.slot,&"a")):
		character.score += 1
		character.play_anim(&"mash")

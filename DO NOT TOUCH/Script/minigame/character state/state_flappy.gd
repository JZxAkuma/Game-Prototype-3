extends CharacterState

func _enter() -> void:
	character.score = 0
	character.play_anim(&"idle")

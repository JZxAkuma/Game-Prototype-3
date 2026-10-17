extends CharacterState

const gravity := 25.0
const flap_strength := 9.0
const max_fall_speed := 20.0

func _enter() -> void:
	character.score = 0
	character.velocity = Vector3.ZERO

func _physics_update(delta: float) -> void:
	if Input.is_action_just_pressed(PlayerInput._act(character.slot, &"a")):
		character.velocity.y = flap_strength

	character.velocity.y = maxf(character.velocity.y - gravity * delta, -max_fall_speed)
	character.velocity.z = 0.0
	character.move_and_slide()

func _exit() -> void:
	character.velocity = Vector3.ZERO

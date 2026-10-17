extends CharacterState

const gravity := 25.0
const flap_strength := 9.0
const max_fall_speed := 20.0

const hit_force := 8.0
const knockback_decay := 25.0

var knockback := Vector3.ZERO

func _enter() -> void:
	character.score = 0
	character.velocity = Vector3.ZERO

func _physics_update(delta: float) -> void:
	knockback = knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	if Input.is_action_just_pressed(PlayerInput._act(character.slot, &"a")):
		character.velocity.y = flap_strength

	character.velocity.y = maxf(character.velocity.y - gravity * delta, -max_fall_speed)
	character.velocity.x = knockback.x
	character.velocity.z = knockback.z
	character.move_and_slide()

func _exit() -> void:
	character.velocity = Vector3.ZERO

func _on_hitbox_hit(victim: PlayerCharacter) -> void:
	if victim.state:
		victim.state._on_hit_received(character)

func _on_hit_received(attacker: PlayerCharacter) -> void:
	var dir := character.global_position - attacker.global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		dir = -attacker.global_basis.z
	knockback = dir.normalized() * hit_force

func _on_respawn() -> void:
	knockback = Vector3.ZERO

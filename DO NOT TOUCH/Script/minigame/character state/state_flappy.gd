extends CharacterState

const gravity := 25.0
const flap_strength := 9.0
const max_fall_speed := 20.0
const air_drag := 3.0

const hit_force := 8.0
const knockback_decay := 25.0

const max_lean_angle := 80.0
const lean_speed := 4.0 
const lean_return_speed := 0.0 

var motion := Vector3.ZERO
var knockback := Vector3.ZERO

var z_lock := 0.0

const lean_sign := 1.0

func _enter() -> void:
	character.score = 0
	character.velocity = Vector3.ZERO
	character.rotation.z = 0.0
	motion = Vector3.ZERO

func _physics_update(delta: float) -> void:
	knockback = knockback.move_toward(Vector3.ZERO, knockback_decay * delta)
	character.velocity = Vector3(motion.x + knockback.x, motion.y, 0.0)
	character.move_and_slide()
	character.global_position.z = z_lock 

	var lean_input := Input.get_axis(
		PlayerInput._act(character.slot, &"left"),
		PlayerInput._act(character.slot, &"right")
	)
	if lean_input != 0.0:
		character.rotation.z += lean_sign * lean_input * lean_speed * delta
	elif lean_return_speed > 0.0:
		character.rotation.z = move_toward(character.rotation.z, 0.0, lean_return_speed * delta)

	var limit := deg_to_rad(max_lean_angle)
	character.rotation.z = clampf(character.rotation.z, -limit, limit)

	if Input.is_action_just_pressed(PlayerInput._act(character.slot, &"a")):
		var up := character.global_basis.y
		motion.x = up.x * flap_strength
		motion.y = up.y * flap_strength

	motion.y = maxf(motion.y - gravity * delta, -max_fall_speed)
	motion.x = move_toward(motion.x, 0.0, air_drag * delta)

	character.velocity = Vector3(motion.x + knockback.x, motion.y, knockback.z)
	character.move_and_slide()

	if character.is_on_floor() and motion.y < 0.0:
		motion.y = 0.0
	if character.is_on_ceiling() and motion.y > 0.0:
		motion.y = 0.0

func _exit() -> void:
	character.velocity = Vector3.ZERO
	character.rotation.z = 0.0
	character.axis_lock_linear_z = false

func _on_hitbox_hit(victim: PlayerCharacter) -> void:
	if victim.state:
		victim.state._on_hit_received(character)

func _on_hit_received(attacker: PlayerCharacter) -> void:
	var dx := character.global_position.x - attacker.global_position.x
	var dir_x := signf(dx)
	if absf(dx) < 0.01:
		dir_x = 1.0 if character.slot > attacker.slot else -1.0

	motion.x = 0.0
	knockback = Vector3(dir_x * hit_force, 0.0, 0.0)

func _on_respawn() -> void:
	knockback = Vector3.ZERO
	motion = Vector3.ZERO
	character.rotation.z = 0.0

func _on_bounce(impulse: Vector3) -> void:
	motion.x = impulse.x
	motion.y = impulse.y
	knockback = Vector3.ZERO

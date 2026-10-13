extends CharacterState

const speed := 5.0
const turn_speed := 12.0

func _enter() -> void:
	pass
	#idle aniamtion


func _physics_update(delta: float) -> void:
	var m := PlayerInput._get_move(character.slot)
	var stunned := character.knockback.length() > 4.0

	var move := Vector3.ZERO if stunned else Vector3(m.x, 0.0, m.y) * speed
	character.velocity.x = move.x + character.knockback.x
	character.velocity.z = move.z + character.knockback.z

	if not stunned and m.length() > 0.1:
		var target_yaw := atan2(-m.x, -m.y)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw, turn_speed * delta)

	character.move_and_slide()
func _exit() -> void:
	character.velocity = Vector3.ZERO

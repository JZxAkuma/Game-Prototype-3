extends CharacterState

const speed := 5.0
const turn_speed := 12.0

func _enter() -> void:
	pass
	#idle aniamtion

func _physics_update(_delta:float) -> void:
	var m := PlayerInput._get_move(character.slot)
	character.velocity.x = m.x * speed
	character.velocity.z = m.y * speed
	
	if m.length() > 0.1:
		var target_yaw := atan2(-m.x,-m.y)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw,turn_speed * _delta)
	
	character.move_and_slide()

func _exit() -> void:
	character.velocity = Vector3.ZERO

extends CharacterState

signal threw(character: PlayerCharacter, dir: Vector3)

const speed := 5.0
const turn_speed := 12.0
const gravity := 20.0
const throw_cooldown := 0.4

var throw_cd := 0.0
var axis := -1
var lo := 0.0
var hi := 0.0


func set_bounds(p_axis: int, p_lo: float, p_hi: float) -> void:
	axis = p_axis
	lo = p_lo
	hi = p_hi


func _enter() -> void:
	character.play_anim(&"idle")


func _physics_update(delta: float) -> void:
	throw_cd = maxf(throw_cd - delta, 0.0)

	var m := PlayerInput._get_move(character.slot)
	character.velocity.x = m.x * speed
	character.velocity.z = m.y * speed
	if character.is_on_floor():
		character.velocity.y = 0.0
	else:
		character.velocity.y -= gravity * delta

	if m.length() > 0.1:
		var target_yaw := atan2(-m.x, -m.y)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw, turn_speed * delta)

	character.move_and_slide()

	if axis != -1:
		var p := character.global_position
		p[axis] = clampf(p[axis], lo, hi)
		character.global_position = p


func _handle_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed(PlayerInput._act(character.slot, &"a")):
		return
	if throw_cd > 0.0:
		return
	throw_cd = throw_cooldown
	var dir := -character.global_basis.z
	dir.y = 0.0
	threw.emit(character, dir.normalized())


func _exit() -> void:
	character.velocity = Vector3.ZERO

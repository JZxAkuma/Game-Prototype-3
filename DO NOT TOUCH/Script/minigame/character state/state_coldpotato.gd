extends CharacterState

signal bumped(toucher: PlayerCharacter, other: PlayerCharacter)

const speed := 5.0
const turn_speed := 12.0
const gravity := 20.0

const knockback_decay := 30.0
const stun_threshold := 4.0

const dash_speed := 16.0
const dash_duration := 0.2
const dash_cooldown := 0.8

var knockback := Vector3.ZERO

var dash_timer := 0.0
var dash_cd := 0.0
var dash_dir := Vector3.ZERO


func _hitbox() -> StringName:
	return &"flappy"


func _enter() -> void:
	character.play_anim(&"idle")


func _physics_update(delta: float) -> void:
	dash_cd = maxf(dash_cd - delta, 0.0)
	dash_timer = maxf(dash_timer - delta, 0.0)
	knockback = knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	var m := PlayerInput._get_move(character.slot)
	var stunned := knockback.length() > stun_threshold
	var dashing := dash_timer > 0.0

	var move := Vector3.ZERO
	if dashing:
		move = dash_dir * dash_speed
	elif not stunned:
		move = Vector3(m.x, 0.0, m.y) * speed

	character.velocity.x = move.x + knockback.x
	character.velocity.z = move.z + knockback.z

	if character.is_on_floor():
		character.velocity.y = 0.0
	else:
		character.velocity.y -= gravity * delta

	if not dashing and not stunned and m.length() > 0.1:
		var target_yaw := atan2(-m.x, -m.y)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw, turn_speed * delta)

	character.move_and_slide()


func _handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(PlayerInput._act(character.slot, &"a")):
		_try_dash()


func _try_dash() -> void:
	if dash_cd > 0.0 or knockback.length() > stun_threshold:
		return
	dash_dir = -character.global_basis.z
	dash_dir.y = 0.0
	dash_dir = dash_dir.normalized()
	dash_timer = dash_duration
	dash_cd = dash_cooldown
	character.play_anim(&"dash")


func _exit() -> void:
	character.velocity = Vector3.ZERO


func _on_hitbox_hit(victim: PlayerCharacter) -> void:
	bumped.emit(character, victim)


func push_from(pos: Vector3, force: float) -> void:
	var dir := character.global_position - pos
	dir.y = 0.0
	if dir.length() < 0.01:
		dir = -character.global_basis.z
	knockback = dir.normalized() * force
	dash_timer = 0.0


func _on_respawn() -> void:
	knockback = Vector3.ZERO
	dash_timer = 0.0
	dash_cd = 0.0

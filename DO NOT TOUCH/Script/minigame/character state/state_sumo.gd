extends CharacterState

signal fell_off(character: PlayerCharacter)

const speed := 5.0
const turn_speed := 12.0
const gravity := 20.0

const hit_force := 12.0
const dash_hit_force := 20.0
const knockback_decay := 30.0

const dash_speed := 16.0
const dash_duration := 0.2
const dash_cooldown := 0.8

var knockback := Vector3.ZERO
var hit_cooldown := 0.0

var dash_timer := 0.0      
var dash_cd := 0.0
var dash_dir := Vector3.ZERO


func _enter() -> void:
	character.play_anim(&"idle")


func _physics_update(delta: float) -> void:
	hit_cooldown = maxf(hit_cooldown - delta, 0.0)
	dash_cd = maxf(dash_cd - delta, 0.0)
	dash_timer = maxf(dash_timer - delta, 0.0)
	knockback = knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	var m := PlayerInput._get_move(character.slot)
	var stunned := knockback.length() > 4.0
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
	if dash_cd > 0.0 or knockback.length() > 4.0:
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
	if victim.state:
		victim.state._on_hit_received(character)


func _on_hit_received(attacker: PlayerCharacter) -> void:
	if hit_cooldown > 0.0:
		return
	hit_cooldown = 0.4


	var attacker_dashing := false
	if attacker.state and attacker.state.get("dash_timer") != null:
		attacker_dashing = attacker.state.dash_timer > 0.0
	var force := dash_hit_force if attacker_dashing else hit_force

	var dir := character.global_position - attacker.global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		dir = -attacker.global_basis.z
	knockback = dir.normalized() * force
	dash_timer = 0.0  
	character.play_anim(&"hit")


func _on_hurtbox_entered(area: Area3D) -> void:
	if area.is_in_group("map_limit"):
		fell_off.emit(character)


func _on_respawn() -> void:
	knockback = Vector3.ZERO
	hit_cooldown = 0.0
	dash_timer = 0.0
	dash_cd = 0.0

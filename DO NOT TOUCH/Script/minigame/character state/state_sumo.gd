extends CharacterState

signal fell_off(character: PlayerCharacter)

const speed := 5.0
const turn_speed := 12.0
const hit_force := 12.0
const knockback_decay := 30.0

var knockback := Vector3.ZERO
var hit_cooldown := 0.0


func _enter() -> void:
	character.play_anim(&"idle")


func _physics_update(delta: float) -> void:
	hit_cooldown = maxf(hit_cooldown - delta, 0.0)
	knockback = knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	var m := PlayerInput._get_move(character.slot)
	var stunned := knockback.length() > 4.0
	var move := Vector3.ZERO if stunned else Vector3(m.x, 0.0, m.y) * speed

	character.velocity.x = move.x + knockback.x
	character.velocity.z = move.z + knockback.z
	
	if !character.is_on_floor():
		character.velocity.y -= 9.8

	if not stunned and m.length() > 0.1:
		var target_yaw := atan2(-m.x, -m.y)
		character.rotation.y = lerp_angle(character.rotation.y, target_yaw, turn_speed * delta)

	character.move_and_slide()


func _exit() -> void:
	character.velocity = Vector3.ZERO


func _on_hitbox_hit(victim: PlayerCharacter) -> void:
	if victim.state:
		victim.state._on_hit_received(character)


func _on_hit_received(attacker: PlayerCharacter) -> void:
	if hit_cooldown > 0.0:
		return
	hit_cooldown = 0.4

	var dir := character.global_position - attacker.global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		dir = -attacker.global_basis.z
	knockback = dir.normalized() * hit_force
	character.play_anim(&"hit")


func _on_hurtbox_entered(area: Area3D) -> void:
	if area.is_in_group("map_limit"):
		fell_off.emit(character)

func _on_respawn() -> void:
	knockback = Vector3.ZERO
	hit_cooldown = 0.0

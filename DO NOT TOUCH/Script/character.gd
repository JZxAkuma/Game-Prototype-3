extends CharacterBody3D
class_name PlayerCharacter

@onready var anim: AnimationPlayer = $AnimationPlayer

enum Mode { LOCKED, BUTTON_MASH, TUG_OF_WAR, RHYTHM, SUMO }

const states := {
	Mode.LOCKED : preload("res://DO NOT TOUCH/Script/minigame/character state/state_locked.gd"),
	Mode.SUMO: preload("res://DO NOT TOUCH/Script/minigame/character state/state_sumo.gd")
}

var slot := 0
var mode := Mode.LOCKED
var state: CharacterState
var score := 0
var knockback := Vector3.ZERO
var hit_cooldown := 0.0

func setup(p_slot: int) -> void:
	slot = p_slot

func set_mode(new_mode: Mode) -> void:
	if state:
		state._exit()
	mode = new_mode
	state = states[new_mode].new()
	state.character = self
	state._enter()

func play_anim(anim_name: StringName) -> void:
	if anim and anim.has_animation(anim_name):
		anim.play(anim_name)

func _physics_process(delta: float) -> void:
	hit_cooldown = maxf(hit_cooldown - delta, 0.0)
	knockback = knockback.move_toward(Vector3.ZERO, 30.0 * delta)  
	if state:
		state._physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if state:
		state._handle_input(event)


func _on_hitbox_area_entered(area: Area3D) -> void:
	var victim := area.owner as PlayerCharacter
	if victim == null or victim == self:
		return
	victim._take_hit(self)

func _take_hit(attacker: PlayerCharacter, force := 12.0) -> void:
	if hit_cooldown > 0.0:
		return
	hit_cooldown = 0.4

	var dir := global_position - attacker.global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		dir = -attacker.global_basis.z 
	knockback = dir.normalized() * force

	play_anim(&"hit")
	if state:
		state._on_hit_received(attacker)

func _on_hurtbox_area_entered(area: Area3D) -> void:
	pass

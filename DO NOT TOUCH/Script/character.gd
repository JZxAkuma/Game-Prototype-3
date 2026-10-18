extends CharacterBody3D
class_name PlayerCharacter

signal state_changed(character: PlayerCharacter, new_state: CharacterState)

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sumo_hitbox: CollisionShape3D = $hitbox/CollisionShape3D
@onready var flappy_hitbox: CollisionShape3D = $"hitbox/flappy hitbox"

var flap_part = preload("res://DO NOT TOUCH/Scene/flappy_fart.tscn")


enum Mode { LOCKED, BUTTON_MASH, TUG_OF_WAR, RHYTHM, SUMO, FLAPPY }

const states := {
	Mode.LOCKED: preload("res://DO NOT TOUCH/Script/minigame/character state/state_locked.gd"),
	Mode.SUMO: preload("res://DO NOT TOUCH/Script/minigame/character state/state_sumo.gd"),
	Mode.FLAPPY : preload("res://DO NOT TOUCH/Script/minigame/character state/state_flappy.gd")
}

var slot := 0
var mode := Mode.LOCKED
var state: CharacterState
var score := 0


func setup(p_slot: int) -> void:
	slot = p_slot

func _flappy_emit() -> void:
	var p = flap_part.instantiate()
	get_parent().add_child(p)
	p.global_transform = global_transform
	


func set_mode(new_mode: Mode) -> void:
	if state:
		state._exit()
	mode = new_mode
	state = states[new_mode].new()
	state.character = self
	state._enter()
	state_changed.emit(self, state)


func play_anim(anim_name: StringName) -> void:
	if anim and anim.has_animation(anim_name):
		anim.play(anim_name)


func _physics_process(delta: float) -> void:
	if state:
		state._physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if state:
		state._handle_input(event)


func _on_hitbox_area_entered(area: Area3D) -> void:
	var victim := area.owner as PlayerCharacter
	if state and victim and victim != self:
		state._on_hitbox_hit(victim)

func _on_hurtbox_area_entered(area: Area3D) -> void:
	if state:
		state._on_hurtbox_entered(area)

func _apply_hitbox(m: Mode) -> void:
	sumo_hitbox.set_deferred("disabled", m != Mode.SUMO)
	flappy_hitbox.set_deferred("disabled", m != Mode.FLAPPY)

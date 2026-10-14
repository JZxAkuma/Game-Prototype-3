extends CharacterBody3D
class_name PlayerCharacter

signal state_changed(character: PlayerCharacter, new_state: CharacterState)

@onready var anim: AnimationPlayer = $AnimationPlayer

enum Mode { LOCKED, BUTTON_MASH, TUG_OF_WAR, RHYTHM, SUMO }

const states := {
	Mode.LOCKED: preload("res://DO NOT TOUCH/Script/minigame/character state/state_locked.gd"),
	Mode.SUMO: preload("res://DO NOT TOUCH/Script/minigame/character state/state_sumo.gd"),
}

var slot := 0
var mode := Mode.LOCKED
var state: CharacterState
var score := 0


func setup(p_slot: int) -> void:
	slot = p_slot


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

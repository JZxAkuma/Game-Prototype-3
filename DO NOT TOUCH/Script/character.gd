extends CharacterBody3D
class_name PlayerCharacter

signal state_changed(character: PlayerCharacter, new_state: CharacterState)

const LOCKED_STATE := preload("res://DO NOT TOUCH/Script/minigame/character state/state_locked.gd")

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area3D = $hitbox

var flap_part = preload("res://DO NOT TOUCH/Scene/flappy_fart.tscn")

var slot := 0
var state: CharacterState
var score := 0

func setup(p_slot: int) -> void:
	slot = p_slot

func set_state(script: GDScript) -> void:
	if state:
		state._exit()
	state = script.new()
	state.character = self
	_apply_hitbox(state._hitbox())
	state._enter()
	state_changed.emit(self, state)


func lock() -> void:
	set_state(LOCKED_STATE)

func _apply_hitbox(shape_name: StringName) -> void:
	for s in hitbox.get_children():
		if s is CollisionShape3D:
			s.set_deferred("disabled", s.name != shape_name)


func play_anim(anim_name: StringName) -> void:
	if anim and anim.has_animation(anim_name):
		anim.play(anim_name)


func _flappy_emit() -> void:
	var p = flap_part.instantiate()
	get_parent().add_child(p)
	p.global_transform = global_transform


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

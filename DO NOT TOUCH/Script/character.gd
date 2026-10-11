extends CharacterBody3D
class_name PlayerCharacter

enum Mode { LOCKED, BUTTON_MASH, TUG_OF_WAR, RHYTHM, SUMO }

var slot := 0
var mode := Mode.LOCKED

func setup(p_slot: int) -> void:
	slot = p_slot

func set_mode(new_mode: Mode) -> void:
	mode = new_mode

func play_anim(anim_name: StringName) -> void:
	pass

class_name CharacterState
extends RefCounted

var character: PlayerCharacter

func _enter() -> void: pass
func _exit() -> void: pass
func _physics_update(_delta: float) -> void: pass
func _handle_input(_event: InputEvent) -> void: pass
func _on_hit_received(_attacker: PlayerCharacter) -> void: pass

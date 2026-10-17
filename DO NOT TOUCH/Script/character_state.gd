class_name CharacterState
extends RefCounted

var character: PlayerCharacter

func _enter() -> void: pass
func _exit() -> void: pass
func _physics_update(_delta: float) -> void: pass
func _handle_input(_event: InputEvent) -> void: pass

func _on_hitbox_hit(_victim: PlayerCharacter) -> void: pass
func _on_hit_received(_attacker: PlayerCharacter) -> void: pass
func _on_hurtbox_entered(_area: Area3D) -> void: pass
func _on_respawn() -> void: pass
func _on_bounce(_impulse: Vector3) -> void: pass

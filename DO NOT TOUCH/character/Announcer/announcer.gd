extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _play_idle() -> void:
	anim.play("AnnouncerAnimations/Idle")

func  _anim_stop() -> void:
	anim.stop()

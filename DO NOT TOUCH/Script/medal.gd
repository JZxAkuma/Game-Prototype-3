class_name Medal
extends Area3D

signal touched(character: PlayerCharacter)

@export var follow_offset := Vector3(0, 2.2, 0)
@export var follow_speed := 15.0

var target: Node3D
var home := Vector3.ZERO

func _ready() -> void:
	home = global_position
	print("medal ready, mask=", collision_mask, " monitoring=", monitoring)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	print("medal touched by area: ", area.name, " owner: ", area.owner)
	var c := area.owner as PlayerCharacter
	if c:
		touched.emit(c)

func _process(delta: float) -> void:
	if is_instance_valid(target):
		var goal := target.global_position + follow_offset
		global_position = global_position.lerp(goal, 1.0 - exp(-follow_speed * delta))

func attach_to(c: Node3D) -> void:
	target = c
	set_deferred("monitoring", false)

func reset() -> void:
	target = null
	global_position = home
	set_deferred("monitoring", true)

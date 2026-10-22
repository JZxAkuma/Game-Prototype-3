

extends MeshInstance3D

@export var follow_speed: float = 5.0
@export var wobble_strength: float = 0.3
@export var wobble_spring: float = 5.0
@export var wobble_damping: float = 2.0
@export_range(0.0, 180.0, 1.0) var max_tilt_degrees: float = 80.0

var initial_rotation: Vector3
var wobble := Vector2.ZERO
var wobble_velocity := Vector2.ZERO
var previous_basis: Basis


func _ready() -> void:
	initial_rotation = rotation
	previous_basis = get_parent().global_transform.basis


func _physics_process(delta: float) -> void:
	var bottle := get_parent() as Node3D
	if bottle == null:
		return

	var basis := bottle.global_transform.basis
	var change := (previous_basis.inverse() * basis).get_euler()
	previous_basis = basis


	wobble_velocity.x -= change.z * wobble_strength
	wobble_velocity.y += change.x * wobble_strength


	wobble_velocity -= wobble * wobble_spring * delta
	wobble_velocity *= exp(-wobble_damping * delta)
	wobble += wobble_velocity * delta
	var gravity := (basis.inverse() * Vector3.DOWN).normalized()
	var target_x := atan2(-gravity.z, -gravity.y)
	var target_z := atan2(gravity.x, -gravity.y)
	var max_tilt := deg_to_rad(max_tilt_degrees)
	target_x = clamp(target_x, -max_tilt, max_tilt)
	target_z = clamp(target_z, -max_tilt, max_tilt)
	target_x += wobble.y
	target_z += wobble.x

	var target := Vector3(
		initial_rotation.x + target_x,
		initial_rotation.y,
		initial_rotation.z + target_z
	)

	rotation = rotation.lerp(
		target,
		1.0 - exp(-follow_speed * delta)
	)

extends MeshInstance3D

@export var open_eye_texture: Texture2D
@export var closed_eye_texture: Texture2D
@export var blink_interval_min: float = 2.0
@export var blink_interval_max: float = 5.0
@export var blink_duration: float = 0.12
@export var surface_index: int = 0
var blink_timer: float = 0.0
var is_blinking: bool = false
var face_material: StandardMaterial3D
func _ready() -> void:
	face_material = get_active_material(surface_index) as StandardMaterial3D

	if face_material == null:
		push_warning("The face needs a StandardMaterial3D.")
		return

	if open_eye_texture == null or closed_eye_texture == null:
		push_warning("Assign both eye textures.")
		return

	# Dup the material so other objects are not affected.
	face_material = face_material.duplicate() as StandardMaterial3D
	set_surface_override_material(surface_index, face_material)

	face_material.albedo_texture = open_eye_texture
	schedule_next_blink()
func schedule_next_blink() -> void:
	blink_timer = randf_range(
		blink_interval_min,
		blink_interval_max
	)
func _process(delta: float) -> void:
	if face_material == null:
		return

	blink_timer -= delta

	if not is_blinking and blink_timer <= 0.0:
		blink()
func blink() -> void:
	is_blinking = true
	face_material.albedo_texture = closed_eye_texture

	await get_tree().create_timer(blink_duration).timeout

	if not is_inside_tree():
		return

	face_material.albedo_texture = open_eye_texture
	is_blinking = false
	schedule_next_blink()

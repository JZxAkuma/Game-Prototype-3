extends MeshInstance3D

@export var flip_interval: float = 1.0

var timer: float = 0.0
var is_flipped: bool = false

func _ready() -> void:
	var mat = get_surface_override_material(0)
	if mat is StandardMaterial3D:
		mat = mat.duplicate()
		set_surface_override_material(0, mat)

func _process(delta: float) -> void:
	timer += delta

	if timer >= flip_interval:
		timer = 0.0
		flip_texture()

func flip_texture() -> void:
	var mat = get_surface_override_material(0)

	if mat is StandardMaterial3D:
		var tex = mat.albedo_texture
		if tex:
			mat.uv1_scale.x = -1.0 if not is_flipped else 1.0
			is_flipped = not is_flipped

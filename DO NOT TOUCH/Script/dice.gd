extends Node3D

@export var spin_speed := Vector3(9.0, 13.0, 7.0)

var default_scale: Vector3

@onready var mesh: Node3D = $Mesh

var spinning := false

const FACE_NORMALS := {
	1: Vector3.BACK,     
	2: Vector3.RIGHT,    
	3: Vector3.UP,       
	4: Vector3.DOWN,     
	5: Vector3.LEFT,     
	6: Vector3.FORWARD, 
}

func _ready() -> void:
	hide()
	default_scale = mesh.scale

func start_spin() -> void:
	show()
	spinning = true


func reveal(value: int) -> void:
	spinning = false

	var cam := get_viewport().get_camera_3d()
	var to_cam := global_basis.inverse() * (cam.global_position - global_position)
	to_cam = to_cam.normalized()

	var normal: Vector3 = FACE_NORMALS[value]
	var q: Quaternion
	if normal.dot(to_cam) < -0.999:
		q = Quaternion(normal.cross(Vector3.UP).normalized(), PI)
	else:
		q = Quaternion(normal, to_cam)
	mesh.quaternion = q

	mesh.scale = default_scale * 1.4
	create_tween().tween_property(mesh, "scale", default_scale, 0.15)


func _process(delta: float) -> void:
	if spinning:
		mesh.rotation += spin_speed * delta

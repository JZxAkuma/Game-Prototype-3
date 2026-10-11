@tool
extends Node3D
class_name BoardSpace

enum Type {BLANK, GAIN, LOSE, EVENT, MINIGAME, SHOP}

const COLORS := [Color.BLACK, Color.GREEN, Color.RED, Color.PURPLE, Color.ORANGE, Color.GOLD]

@export var type: Type = Type.BLANK:
	set(v):
		type = v
		if is_node_ready():
			_refresh_visual()

@export var locked := false
@export var next_override: Array[NodePath] = []

var index := -1
var next:Array[BoardSpace] = []

var _mat := StandardMaterial3D.new()

@onready var mesh: MeshInstance3D = $mesh
@onready var anchor: Marker3D = $Marker3D


func _ready() -> void:
	mesh.material_override = _mat
	_refresh_visual()

func _refresh_visual() -> void:
	_mat.albedo_color = COLORS[type]

func get_anchor_position() -> Vector3:
	return anchor.global_position

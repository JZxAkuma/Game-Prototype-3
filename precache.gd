extends Node3D


@export var scenes_to_render: Array[PackedScene] = []
@export_file("*.tscn") var next_scene := "res://DO NOT TOUCH/Scene/main.tscn"

@onready var progress_label: Label = $CanvasLayer/Label

var done := 0
var total := 0


func _ready() -> void:
	total = scenes_to_render.size() 
	await get_tree().process_frame
	await _render_scenes()
	get_tree().change_scene_to_file(next_scene)




func _render_scenes() -> void:
	for scene in scenes_to_render:
		var inst := scene.instantiate()
		add_child(inst)
		if inst is Node3D:
			inst.position = Vector3(0, 0, -3) 
		_kick_particles(inst)

		await get_tree().process_frame
		await get_tree().process_frame
		_tick()

		inst.queue_free()
		await get_tree().process_frame


func _kick_particles(node: Node) -> void:
	if node is GPUParticles3D:
		node.restart()
		node.emitting = true
	elif node is CPUParticles3D:
		node.restart()
		node.emitting = true
	for c in node.get_children():
		_kick_particles(c)


func _tick() -> void:
	done += 1
	progress_label.text = "Pre-caching\n%d / %d" % [done, total]

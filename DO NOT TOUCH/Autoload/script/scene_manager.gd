extends Node

signal scene_changed()

var current_scene : Node
var busy := false

var _container : Node

func register_container(container:Node3D) -> void:
	_container = container
	current_scene = container.get_child(0) if container.get_child_count() > 0 else null

func goto_scene(scene: PackedScene, setup:Callable = Callable()) -> void:
	assert(_container != null, "Scene Manager: register_container() was not called")
	if busy: 
		return
	busy = true
	swap(scene,setup)

func swap(scene:PackedScene, setup:Callable) -> void:
	if current_scene:
		await Transition.fade_in()
		var old := current_scene
		current_scene = null
		old.queue_free()
		await old.tree_exited
	
	var next := scene.instantiate()
	if setup.is_valid():
		setup.call(next)
	_container.add_child(next)
	current_scene = next
	
	await get_tree().process_frame
	await Transition.fade_out()
	
	busy = false
	scene_changed.emit(next)

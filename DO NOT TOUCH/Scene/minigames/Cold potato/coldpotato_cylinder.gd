extends CSGCylinder3D

var max_height = 0.0
var min_height = -1.4
var speed = 1.0


func _ready() -> void:
	var starting = randf_range(-0.2, -1.2)
	position.y = starting 

func _process(delta: float) -> void:
	position.y += speed * delta
	

	if position.y > max_height:
		position.y = max_height
		_switch()

	elif position.y < min_height:
		position.y = min_height
		_switch()

func _switch() -> void:
	speed = -speed 

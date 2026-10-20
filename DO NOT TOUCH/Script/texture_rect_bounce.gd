extends TextureRect

@export var bounce_height: float = 3.0
@export var bounce_speed: float = 3.0
@export_range(0.0, 50) var squash_amount: float = 0.06
@export_range(0.0, 50) var stretch_amount: float = 0.08

var elapsed_time: float = 0.0
var original_position: Vector2
var original_scale: Vector2

func _ready() -> void:
	original_position = position
	original_scale = scale
	pivot_offset = Vector2(size.x * 0.5, size.y)

func _process(delta: float) -> void:
	elapsed_time += delta
	var cycle: float = (sin(elapsed_time * bounce_speed) + 1.0) * 0.5
	position = original_position
	position.y -= cycle * bounce_height
	var horizontal_scale: float = 1.0 - (1.0 - cycle) * squash_amount
	var vertical_scale: float = 1.0 + cycle * stretch_amount

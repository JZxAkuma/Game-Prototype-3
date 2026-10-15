extends TextureRect

@export var zoom_amount: float = 0.1
@export var interval: float = 1.0

var tween: Tween
var original_scale: Vector2


func _ready() -> void:
	original_scale = scale
	pivot_offset = size / 2.0
	start_zoom()


func start_zoom() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		self,
		"scale",
		original_scale * (1.0 + zoom_amount),
		interval
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"scale",
		original_scale,
		interval
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

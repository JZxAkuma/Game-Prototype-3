extends Area3D

@export var fall_speed := 3.0
@export var bounce_strength := 12.0
@export var lifetime := 12.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	global_position.y -= fall_speed * delta


func _on_body_entered(body: Node3D) -> void:
	print("body")
	var c := body as PlayerCharacter
	if c == null or c.state == null:
		return
	var dir := c.global_position - global_position
	dir.z = 0.0
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.UP
	c.state._on_bounce(dir * bounce_strength)

extends CharacterBody3D

@export var MOUSE_SENSITIVITY: float = 0.003
@onready var parent_body: Node3D = $"."

const LOOK_LIMIT_UP: float = -1.4
const LOOK_LIMIT_DOWN: float = 1.4  

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera: Camera3D = $Node3D/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if parent_body:
			parent_body.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		camera.rotation.x = clamp(camera.rotation.x, LOOK_LIMIT_UP, LOOK_LIMIT_DOWN)
		

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("shift"):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("control"):
		velocity.y = -JUMP_VELOCITY
	else:
		velocity.y = 0
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

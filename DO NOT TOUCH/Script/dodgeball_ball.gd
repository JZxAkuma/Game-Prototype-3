class_name DodgeBall
extends Area3D

signal hit_character(ball: DodgeBall, character: PlayerCharacter)
signal pick_requested(ball: DodgeBall, character: PlayerCharacter)

@export var bounce_keep := 0.25
@export var friction := 40.0      
@export var hold_offset := Vector3(0, 1.8, 0)

var velocity := Vector3.ZERO
var team := -1
var live := false
var holder: Node3D


func _ready() -> void:
	area_entered.connect(_on_area)
	body_entered.connect(_on_body)


func _physics_process(delta: float) -> void:
	if holder:
		global_position = holder.global_position + hold_offset
		return

	global_position += velocity * delta
	if not live:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		for a in get_overlapping_areas():
			var c := a.owner as PlayerCharacter
			if c:
				pick_requested.emit(self, c)
				if holder:
					return


func release(vel: Vector3, p_team: int) -> void:
	holder = null
	velocity = vel
	team = p_team
	live = true


func drop() -> void:
	holder = null
	velocity = Vector3.ZERO
	live = false


func _go_dead() -> void:
	if not live:
		return
	live = false
	velocity = -velocity * bounce_keep


func _on_area(area: Area3D) -> void:
	if holder or not live:
		return
	var c := area.owner as PlayerCharacter
	if c:
		if c.slot % 2 != team:
			hit_character.emit(self, c)
			_go_dead()
		return

	if area.is_in_group("wall"):
		_go_dead()
		return

	var other := area as DodgeBall
	if other and other.holder == null and not other.live:
		other.release(velocity, team)

func _on_body(body: Node3D) -> void:
	if live and not holder and body.is_in_group("wall"):
		_go_dead()

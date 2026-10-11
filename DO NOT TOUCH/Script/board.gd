extends Node3D
class_name Board

@onready var spaces_root: Node3D = $Spaces

var spaces: Array[BoardSpace] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_collect_spaces()
	_link_spaces()
	randomize_types(12345, {
		BoardSpace.Type.BLANK: 4.0,
		BoardSpace.Type.GAIN: 3.0,
		BoardSpace.Type.LOSE: 2.0,
		BoardSpace.Type.EVENT: 1.0,
		BoardSpace.Type.MINIGAME: 1.0,
		BoardSpace.Type.SHOP: 1.0,
	})
	
func _collect_spaces() -> void:
	spaces.clear()
	for child in spaces_root.get_children():
		if child is BoardSpace:
			child.index = spaces.size()
			spaces.append(child)

func _link_spaces() -> void:
	for s in spaces:
		s.next.clear()
		if s.next_override.is_empty():
			s.next.append(spaces[(s.index + 1) % spaces.size()])
		else:
			for path in s.next_override:
				s.next.append(s.get_node(path) as BoardSpace)

#func _randomize_types(rng_seed:int, weights:Dictionary) -> void:
	#var rng:= RandomNumberGenerator.new()
	#rng.seed = rng_seed
	#for s in spaces:
		#if s.locked:
			#continue
		#s.type = _weighted_pick(rng, weights)

func randomize_types(rng_seed: int, weights: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var free: Array[BoardSpace] = []
	for s in spaces:
		if not s.locked:
			free.append(s)

	for i in range(free.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := free[i]
		free[i] = free[j]
		free[j] = tmp

	
	var guaranteed: Array = weights.keys()
	var idx := 0
	for t in guaranteed:
		if idx >= free.size():
			push_warning("Board has fewer free squares than space types, can't guarantee all.")
			break
		free[idx].type = t
		idx += 1

	while idx < free.size():
		free[idx].type = _weighted_pick(rng, weights)
		idx += 1

func _weighted_pick(rng: RandomNumberGenerator,weights:Dictionary) -> BoardSpace.Type:
	var total := 0.0
	for w in weights.values():
		total += w
	var roll := rng.randf() * total
	for t in weights:
		roll -= weights[t]
		if roll <= 0.0:
			return t
	
	return BoardSpace.Type.BLANK

func move_token(token: Node3D, from: BoardSpace, steps: int) -> BoardSpace:
	var current := from
	for i in steps:
		current = current.next[0]
		var start := token.global_position
		var end := current.get_anchor_position()
		var tw := create_tween()
		tw.tween_method(func(t: float) -> void:
			var p := start.lerp(end, t)
			p.y += sin(t * PI) * 0.6
			token.global_position = p
		, 0.0, 1.0, 0.3)
		await tw.finished
	return current
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

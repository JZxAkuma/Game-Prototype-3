extends Node3D
class_name Board

@onready var spaces_root: Node3D = $Spaces
@onready var tokens_root: Node3D = $Tokens
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var play_camera_pivot: Node3D = $"play camera pivot"

@onready var announcer_actor: Node3D = $"commentator set/Announcer"


var spaces: Array[BoardSpace] = []
var tokens := {}

const WEIGHTS := {
	BoardSpace.Type.BLANK: 4.0,
	BoardSpace.Type.GAIN: 3.0,
	BoardSpace.Type.LOSE: 2.0,
	BoardSpace.Type.EVENT: 1.0,
	BoardSpace.Type.MINIGAME: 1.0,
	BoardSpace.Type.SHOP: 1.0,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_collect_spaces()
	_link_spaces()
	randomize_types(GameState.board_seed,WEIGHTS)
	
	_spawn_characters()
	
	if SceneManager.busy:
		await SceneManager.scene_changed

	_run_game()

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

func _play_intro() -> void:
	if not anim.has_animation(&"intro"):
		return
	anim.play(&"intro")

	var skipping := false
	while anim.is_playing() and anim.current_animation == &"intro":
		if not skipping and _any_a_pressed():
			skipping = true
			anim.speed_scale = 50.0  
		await get_tree().process_frame
		if not is_inside_tree():
			return

	anim.speed_scale = 1.0

func _any_a_pressed() -> bool:
	for p in GameState.players:
		if Input.is_action_just_pressed(PlayerInput._act(p.slot, &"a")):
			return true
	return false

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

func _spawn_characters() -> void:
	for p in GameState.players:
		var c : PlayerCharacter = GameState.character_scenes[p.character].instantiate()
		tokens_root.add_child(c)
		c.setup(p.slot)
		c.set_mode(PlayerCharacter.Mode.LOCKED)
		c.global_position = spaces[p.space_index].get_anchor_position()
		tokens[p.slot] = c

func _move_token(token: PlayerCharacter, from: BoardSpace, steps: int) -> BoardSpace:
	var current := from
	for i in steps:
		
		current = current.next[0]
		var start := token.global_position
		var end := current.get_anchor_position()
		var flat := Vector3(end.x, start.y, end.z)
		if not flat.is_equal_approx(start):
			token.look_at(flat, Vector3.UP)
		var tw := create_tween()
		tw.tween_method(func(t: float) -> void:
			var p := start.lerp(end, t)
			p.y += sin(t * PI) * 0.6
			token.global_position = p
		, 0.0, 1.0, 0.3)
		await tw.finished
		if not is_inside_tree():
			return current
	return current

func _run_game() -> void:
	if not GameState.intro_played:
		GameState.intro_played = true
		await _play_intro()
		if not is_inside_tree():
			return

	while is_inside_tree():
		await _play_turn(GameState.current_player)
		if not is_inside_tree():
			return
		GameState._next_player()

		if GameState.current_player == 0:
			var mg := GameState.pick_minigame()
			SceneManager.goto_scene(mg.mini_game_scene)
			return


func _play_turn(player_index: int) -> void:
	var p := GameState.players[player_index]
	var a := PlayerInput._act(p.slot, &"a")
	while not Input.is_action_just_pressed(a):
		await get_tree().process_frame
		if not is_inside_tree():
			return
	var roll := randi_range(1,6)
	print("P%d rolled %d" % [p.slot + 1, roll])
	
	var landed := await _move_token(tokens[p.slot],spaces[p.space_index],roll)
	if not is_inside_tree():
		return
	p.space_index = landed.index

	match landed.type:
		BoardSpace.Type.GAIN:
			p.coins += 3
		BoardSpace.Type.LOSE:
			p.coins = max(0, p.coins - 3)
		_:
			pass

func _transition_fade_in() -> void:
	Transition.fade_in()

func _transition_fade_out() -> void:
	Transition.fade_out()

func _cam_transition() -> void:
	Transition.cam_trans()

func _announcer_idle() -> void:
	announcer_actor._play_idle()

func _announcer_stop() -> void:
	announcer_actor._anim_stop()

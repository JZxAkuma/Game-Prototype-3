extends Node3D
class_name Board

@onready var spaces_root: Node3D = $Spaces
@onready var tokens_root: Node3D = $Tokens
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var play_camera_pivot: Node3D = $"play camera pivot"

@onready var announcer_actor: Node3D = $"commentator set/Announcer"

@onready var dice: Node3D = $Dice

@export var cam_follow_speed := 4.0
@export var cam_offset := Vector3.ZERO
var cam_target: Node3D
var cam_follow_enabled := false

const PICKER := preload("res://DO NOT TOUCH/Scene/minigame_picker.tscn")

@export var face_cam_speed := 8.0
var moving_token: Node3D

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

@export var share_radius := 0.7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_collect_spaces()
	_link_spaces()
	randomize_types(GameState.board_seed,WEIGHTS)
	
	_spawn_characters()
	
	#if SceneManager.busy:
		#await SceneManager.scene_changed

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

func _process(delta: float) -> void:
	_follow_cam(delta)
	_face_tokens_to_camera(delta)

	if Input.is_action_just_pressed("sumo"):
		_debug_minigame("sumo")
	elif Input.is_action_just_pressed("flappy"):
		_debug_minigame("flappy")
	elif Input.is_action_just_pressed("button mash"):
		_debug_minigame("button mash")
	elif Input.is_action_just_pressed("cold potato"):
		_debug_minigame("cold_potato")

func _debug_minigame(id: String) -> void:
	var mg := GameState.pick_minigame_by_id(id)
	if mg == null:
		push_warning("No minigame '%s' in GamesState" % id)
		return
	SceneManager.goto_scene(mg.mini_game_scene)

func _face_tokens_to_camera(delta: float) -> void:
	if not tokens_root.visible:
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	for token in tokens.values():
		if token == moving_token:
			continue
		var dir: Vector3 = cam.global_position - token.global_position
		dir.y = 0.0
		if dir.length() < 0.01:
			continue
		var target_yaw := atan2(-dir.x, -dir.z)
		token.rotation.y = lerp_angle(token.rotation.y, target_yaw, face_cam_speed * delta)

func _follow_cam(delta:float) -> void:
	if not cam_follow_enabled or cam_target == null:
		return
	var goal := cam_target.global_position + cam_offset
	var t := 1.0 - exp(-cam_follow_speed * delta)
	play_camera_pivot.global_position = play_camera_pivot.global_position.lerp(goal, t)

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

	for p in GameState.players:
		_arrange_space(p.space_index, false)

func _move_token(token: PlayerCharacter, from: BoardSpace, steps: int) -> BoardSpace:
	moving_token = token
	_arrange_space(from.index)
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

	moving_token = null
	return current

func _run_game() -> void:
	_play_cam_current()
	if not GameState.intro_played:
		GameState.intro_played = true
		await _play_intro()
		if not is_inside_tree():
			return

	_show_tokens()
	var first := GameState.players[GameState.current_player]
	play_camera_pivot.global_position = tokens[first.slot].global_position + cam_offset
	cam_follow_enabled = true

	while is_inside_tree():
		await _play_turn(GameState.current_player)
		if not is_inside_tree():
			return
		GameState._next_player()

		if GameState.current_player == 0:
			var mg := GameState.pick_minigame()
			await _show_picker(mg)
			if not is_inside_tree():
				return
			SceneManager.goto_scene(mg.mini_game_scene)
			return

func _play_turn(player_index: int) -> void:
	var p := GameState.players[player_index]
	cam_target = tokens[p.slot]

	dice.global_position = tokens[p.slot].global_position + Vector3(0, 4.0, 0)
	dice.start_spin()

	var a := PlayerInput._act(p.slot, &"a")
	while not Input.is_action_just_pressed(a):
		await get_tree().process_frame
		if not is_inside_tree():
			return

	var roll := randi_range(1, 6)
	dice.reveal(roll)
	_hop(tokens[p.slot])
	tokens[p.slot].play_anim(&"jump")
	await get_tree().create_timer(0.6).timeout
	if not is_inside_tree():
		return
	dice.hide()
	
	var landed := await _move_token(tokens[p.slot],spaces[p.space_index],roll)
	if not is_inside_tree():
		return
	p.space_index = landed.index
	moving_token = null
	_arrange_space(landed.index)

	match landed.type:
		BoardSpace.Type.GAIN:
			p.coins += 3
		BoardSpace.Type.LOSE:
			p.coins = max(0, p.coins - 3)
		_:
			pass

func _occupants(space_index: int) -> Array:
	var list := []
	for p in GameState.players:
		if p.space_index != space_index:
			continue
		var t = tokens.get(p.slot)
		if t == null or t == moving_token:
			continue
		list.append(p)
	return list

func _slot_position(p, list: Array) -> Vector3:
	var base := spaces[p.space_index].get_anchor_position()
	if list.size() <= 1:
		return base
	var angle := TAU * list.find(p) / list.size()
	return base + Vector3(cos(angle), 0.0, sin(angle)) * share_radius

func _arrange_space(space_index: int, animate := true) -> void:
	var list := _occupants(space_index)
	for p in list:
		var token: Node3D = tokens[p.slot]
		var target := _slot_position(p, list)
		if animate:
			create_tween().tween_property(token, "global_position", target, 0.2)
		else:
			token.global_position = target

func _show_picker(winner: MINI_GAME) -> void:
	var picker := PICKER.instantiate()
	add_child(picker)
	picker._play(GameState._get_all_minigames(), winner)
	await picker.finished
	picker.queue_free()

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

func _play_cam_current() -> void:
	$"commentator set/Commentator set wide".current = false
	$"commentator set/commentator set cam".current = false
	$"play camera pivot/play_camera".current = true
	$"droneshot pivot/intro_camera".current = false

func _show_tokens() -> void:
	$CanvasLayer/Control.show()
	tokens_root.show()

func _hop(token: Node3D, height := 0.5, duration := 0.35) -> void:
	var base_y := token.global_position.y
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void:
		var pos := token.global_position
		pos.y = base_y + sin(t * PI) * height
		token.global_position = pos
	, 0.0, 1.0, duration)
	await tw.finished

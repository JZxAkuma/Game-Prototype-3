extends Node3D
class_name MiniGameBase

enum State {tutorial, play, results}

const board := preload("res://DO NOT TOUCH/Scene/board.tscn")

@export var play_mode : PlayerCharacter.Mode = PlayerCharacter.Mode.SUMO
@export var players_root : Node3D
@export var spawns : Node3D
@export var tutorial_ui: CanvasLayer
@export var anim : AnimationPlayer

@warning_ignore("unused_signal")
signal round_over(winner_slot: int)

var state := State.tutorial
var chars := {}
var spawn_of := {}


func _ready() -> void:
	_spawn_characters()
	tutorial_ui._setup(GameState.current_minigame, GameState.players)
	if SceneManager.busy:
		await SceneManager.scene_changed
	_run()


func _spawn_characters() -> void:
	for i in GameState.players.size():
		var p := GameState.players[i]
		var c: PlayerCharacter = GameState.character_scenes[p.character].instantiate()
		players_root.add_child(c)
		c.setup(p.slot)
		spawn_of[p.slot] = spawns.get_child(i)
		chars[p.slot] = c
	_respawn_all()


func _respawn_one(c: PlayerCharacter) -> void:
	c.process_mode = Node.PROCESS_MODE_INHERIT
	c.show()
	c.global_transform = spawn_of[c.slot].global_transform
	c.velocity = Vector3.ZERO
	if c.state:
		c.state._on_respawn()


func _respawn_all() -> void:
	for c in chars.values():
		_respawn_one(c)
		c.set_mode(PlayerCharacter.Mode.LOCKED)
		c.play_anim(&"idle")


func _run() -> void:
	state = State.tutorial
	tutorial_ui._begin()

	_start_round(true)
	tutorial_ui.all_ready.connect(func(): round_over.emit(-1))
	var practicing := true
	while practicing:
		await round_over
		if not is_inside_tree(): return
		if tutorial_ui._is_everyone_ready():
			practicing = false
		else:
			_respawn_all()
			_start_round(true)
	tutorial_ui.hide()

	_respawn_all()
	await _countdown()
	if not is_inside_tree(): return
	state = State.play
	_start_round(false)
	var winner_slot: int = await round_over
	if not is_inside_tree(): return

	state = State.results
	for c in chars.values():
		c.set_mode(PlayerCharacter.Mode.LOCKED)
	for p in GameState.players:
		if p.slot == winner_slot:
			GameState._add_medal(p,1)
			chars[p.slot].play_anim(&"win")
		else:
			chars[p.slot].play_anim(&"lose")
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		SceneManager.goto_scene(board)

func _countdown() -> void:
	#await get_tree().create_timer(2.0).timeout
	anim.play(&"countdown")
	await anim.animation_finished

func _start_round(_practice: bool) -> void:
	for c in chars.values():
		c.set_mode(play_mode)

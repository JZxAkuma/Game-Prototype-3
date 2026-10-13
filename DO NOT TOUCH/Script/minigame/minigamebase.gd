extends Node3D
class_name  MiniGameBase

enum State {tutorial, play, results}

const board:= preload("res://DO NOT TOUCH/Scene/board.tscn")

@export var play_mode : PlayerCharacter.Mode = PlayerCharacter.Mode.SUMO
@export var players_root : Node3D
@export var spawns : Node3D
@onready var tutorial_ui: CanvasLayer = $"Tutorial layer"

@warning_ignore("unused_signal")
signal round_over(winner_slot: int)

var state := State.tutorial
var chars := {}

func _ready() -> void:
	_spawn_characters()
	_run()

func _spawn_characters() -> void:
	for i in GameState.players.size():
		var p := GameState.players[i]
		var c: PlayerCharacter = GameState.character_scenes[p.character].instantiate()
		players_root.add_child(c)
		c.setup(p.slot)
		c.global_transform = spawns.get_child(i).global_transform
		c.play_anim(&"idle")
		chars[p.slot] = c

func _respawn_all() -> void:
	for i in GameState.players.size():
		var c: PlayerCharacter = chars[GameState.players[i].slot]
		c.global_transform = spawns.get_child(i).global_transform
		c.velocity = Vector3.ZERO
		c.set_mode(PlayerCharacter.Mode.LOCKED)

func _run() -> void:
	state = State.tutorial
	tutorial_ui._setup(GameState.current_minigame,GameState.players)
	
	_start_round(true)
	tutorial_ui.all_ready.connect(func(): round_over.emit(-1))
	var practicing := true
	while practicing:
		var winner: int = await  round_over
		if not is_inside_tree(): return
		if tutorial_ui._is_everyone_ready():
			practicing = false
		else:
			_respawn_all()
			_start_round(true)
	
	#--play--
	_respawn_all()
	await  _countdown()
	if not is_inside_tree(): return
	state = State.play
	_start_round(false)
	var winner_slot: int = await round_over
	if not is_inside_tree(): return
	
	#-Result-
	state = State.results
	for c in chars.values():
		c.set_mode(PlayerCharacter.Mode.LOCKED)
	for p in GameState.players:
		if p.slot == winner_slot:
			p.coins += 5
			#character animation win
		else:
			#lose animation
			pass
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		SceneManager.goto_scene(board)

func _countdown() -> void:
	await  get_tree().create_timer(2.0).timeout


func _start_round(_practice: bool) -> void:
	for c in chars.values():
		c.set_mode(play_mode)

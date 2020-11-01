extends Node2D

enum {PASSIVE, SUSPICIOUS, ACTIVE}

const arrow: PackedScene = preload("res://tscn/Javelin.tscn")
const spell: PackedScene = preload("res://tscn/Spell.tscn")

onready var ui: Control = $CanvasLayer/UI
onready var navigation: Navigation2D = $Navigation2D
onready var animation: AnimationPlayer = $AnimationPlayer
onready var defeat_shader = $CanvasLayer/Shaders/DefeatShader.get_material()
onready var player: Player = $Player
onready var camera: Camera2D = $Camera2D

const guards = preload("res://scripts/Guard.gd")
const ennemies = preload("res://scripts/Ennemies.gd")

var lights: Array
var state
var last_player_pos: Vector2
var jav_node: Javelin
var current_state

# warning-ignore:unused_signal
signal siren


func _ready() -> void:
	#start fmod
	AudioSystem.start()
	Fmod.add_listener(0, player)
	#game start in passive state
	state = PASSIVE
	#reset shader
	defeat_shader.set_shader_param("intensity", 1)
	#populate lights array
	lights = get_tree().get_nodes_in_group("lights")

	var _c = connect("siren", AudioSystem, "alert")


func _process(_delta: float) -> void:
	state = get_state()
	set_music_and_lights()


func get_state():
	#check if player is heard or seen by ennemies
	var e = get_tree().get_nodes_in_group("ennemies")
	for i in range (e.size()):
		if e[i].state == ennemies.CHASING or e[i].state == ennemies.INVOQUING or e[i].state == ennemies.CASTING:
			return ACTIVE
	for i in range (e.size()):
		if e[i].state == ennemies.SUSPICIOUS or e[i].state == ennemies.LOOKING:
			return SUSPICIOUS
	return PASSIVE


func set_music_and_lights() -> void:
	#music and lights behaviour based on gameplay dynamic  
	if current_state == state:
		return
	current_state = state
	match state:
		PASSIVE:
			Fmod.set_global_parameter_by_name("State", 0)
			for i in range (lights.size()):
				lights[i].lights_off()
		SUSPICIOUS:
			Fmod.set_global_parameter_by_name("State", 1)
			for i in range (lights.size()):
				lights[i].lights_on()
		ACTIVE:
			alert()
			Fmod.set_global_parameter_by_name("State", 2)
			for i in range (lights.size()):
				lights[i].lights_red()


func alert() -> void:
	#play siren sound fx
	call_deferred("emit_signal", "siren")


func javelin(aiming_at: Vector2, pos: Vector2) -> void:
	#instance player javelin 
	var j: Javelin = arrow.instance()
	j.init(aiming_at, pos)
	add_child(j)
	var path = j.get_path()
	jav_node = get_node(path)


func cast(pos: Vector2) -> void:
	#instance priest spell
	if not camera.is_on_current_panel(pos):
		return
	var n = get_tree().get_nodes_in_group("spells")
	if n.size() > 0:
		return
	var s: Spell = spell.instance()
	s.init(pos)
	add_child(s)


func _on_trigger(id: int) -> void:
	#switch send id to doors and traps
	get_tree().call_group("doors","trigger",id)
	get_tree().call_group("traps","trigger",id)


func set_last_player_pos() -> void:
	#store player last position for guards investigation
	var guards_number = get_tree().get_nodes_in_group("guards")
	for guards in guards_number:
		guards.sound_source = navigation.get_closest_point(last_player_pos)


func defeat() -> void:
	#stop fmod
	AudioSystem.stop()
	#animation shader
	var t = player.get_global_transform_with_canvas().origin
	t.x = clamp(t.x, 0, get_viewport_rect().size.x) / get_viewport_rect().size.x
	t.y = clamp(t.y, 0, get_viewport_rect().size.y) / get_viewport_rect().size.y
	defeat_shader.set_shader_param("target", t)
	animation.play("defeat")
	yield(animation, "animation_finished")
	#pause game before reloading
	get_tree().paused = true
	var _r = get_tree().reload_current_scene()


func victory() -> void:
	#animation shader
	var t = player.get_global_transform_with_canvas().origin
	t.x = clamp(t.x, 0, get_viewport_rect().size.x) / get_viewport_rect().size.x
	t.y = clamp(t.y, 0, get_viewport_rect().size.y) / get_viewport_rect().size.y
	defeat_shader.set_shader_param("target", t)
	animation.play("victory")
	yield(animation, "animation_finished")
	ui.success()

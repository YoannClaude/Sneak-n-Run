extends Node2D

enum {PASSIVE, ACTIVE, SUSPICIOUS}

const arrow: PackedScene = preload("res://tscn/Javelin.tscn")

onready var animation: AnimationPlayer = $AnimationPlayer
onready var defeat_shader = $CanvasLayer/Shaders/DefeatShader.get_material()
onready var player: Player = $Player

var state
var current_scene: String = Globals.games["Tutorial"]
var jav_node: Javelin
var last_player_pos: Vector2


func _ready() -> void:
	defeat_shader.set_shader_param("intensity", 1)
	Fmod.add_listener(0, player)
	

func javelin(aiming_at: Vector2, pos: Vector2) -> void:
	#instance javelin
	var j: Javelin = arrow.instance()
	j.init(aiming_at, pos)
	add_child(j)
	var path = j.get_path()
	jav_node = get_node(path)


func _on_trigger(id: int) -> void:
	get_tree().call_group("doors","trigger",id)


func end_tutorial() -> void:
	var t = player.get_global_transform_with_canvas().origin
	t.x = clamp(t.x, 0, get_viewport_rect().size.x) / get_viewport_rect().size.x
	t.y = clamp(t.y, 0, get_viewport_rect().size.y) / get_viewport_rect().size.y
	defeat_shader.set_shader_param("target", t)
	animation.play("victory")
	yield(animation, "animation_finished")
	Globals.load_new_scene(Globals.games["Sneak'n'Run"])


func _on_EndZone_body_entered(body:Player) -> void:
	if not body:
		return
	end_tutorial()

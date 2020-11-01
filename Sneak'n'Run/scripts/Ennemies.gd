extends KinematicBody2D

class_name Ennemies

export (String, "Down", "Up", "Left", "Right") var facing

enum {STATIC, LOOKING, GETTING_CALM, CHASING, SUSPICIOUS, TRAPPED, PATROLING, INVOQUING, CASTING}

var facing_dir: Dictionary = {"Down": Vector2(0,1),
								 "Up": Vector2(0,-1),
								 "Left": Vector2(-1,0),
								 "Right": Vector2(1,0)}


onready var player: Player = get_node("../../Player")
onready var root: Node2D = get_node("../..")
onready var camera: Camera2D = get_node("../../Camera2D")
onready var navigation: Navigation2D = get_node("../../Navigation2D")
onready var animation_tree: AnimationTree = $AnimationTree
onready var playback = animation_tree.get("parameters/playback")
onready var visnot: VisibilityNotifier2D = $VisibilityNotifier2D

var state
var velocity: Vector2
var action: String
var stunned: bool
var surprised: bool
var rng: RandomNumberGenerator
var random_speed_mod: float

const point_nb: int = 4
const pt0: Vector2 = Vector2()
const pt1: Dictionary = {"Down": Vector2(120,260), "Up": Vector2(120,-260), "Left": Vector2(-260,120), "Right": Vector2(260,120)}
const pt2: Dictionary = {"Down": Vector2(0,280), "Up": Vector2(0,-280), "Left": Vector2(-280,0), "Right": Vector2(280,0)}
const pt3: Dictionary = {"Down": Vector2(-120,260), "Up": Vector2(-120,-260), "Left": Vector2(-260,-120), "Right": Vector2(260,-120)}
var points: Array = [pt0, pt1["Down"], pt2["Down"], pt3["Down"]]


func get_direction(d: Vector2):
	#direction used to set animation from velocity
	if d == null:
		return null
	if (d.y>d.x and d.x>=0) or (d.y>-d.x and d.x<=0):
		return "Down"
	if (-d.y>d.x and d.x>=0) or (-d.y>-d.x and d.x<=0):
		return "Up"
	if (-d.x>d.y and d.y>=0) or (-d.x>-d.y and d.y<=0):
		return "Left"
	if (d.x>d.y and d.y>=0) or (d.x>-d.y and d.y<=0):
		return "Right"

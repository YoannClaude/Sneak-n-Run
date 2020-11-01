extends KinematicBody2D

class_name Trap
 
export var id = 0

onready var collision: CollisionShape2D = $CollisionShape2D
onready var area_2d: Area2D = $Area2D
onready var sprite: TileMap = $TileMap2
onready var player: Player = get_node("../../../Player")

var open: bool = false


func _ready() -> void:
	collision.disabled = true
	area_2d.monitoring = false


func trigger(_id) -> void:
    #set pan and volume of sound fx based on trap position and distance from player
	var d = global_position.distance_to(player.global_position)
	var p = global_position.x - player.global_position.x
	if _id == id:
		if not open:
			area_2d.monitoring = true
			sprite.visible = false
			collision.disabled = false
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Trap", self, {"ToggleTrap": 1, "TrapDistance": d, "TrapPan":p})
			open = true
		else:
			area_2d.monitoring = false
			sprite.visible = true
			collision.disabled = true
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Trap", self, {"ToggleTrap": 0, "TrapDistance": d, "TrapPan":p})
			open = false


func _on_Area2D_body_entered(body: Guard) -> void:
	if open:
		if not body:
			return
		body.get_trapped(global_position + Vector2(64, 64))

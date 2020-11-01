extends KinematicBody2D

export var id: int = 0

onready var collision: CollisionShape2D = $CollisionShape2D
onready var player: Player = get_node("../../../Player")

var open: bool = false


func trigger(_id: int) -> void:
	#get door position to set fx panning and distance from player
	var d = global_position.distance_to(player.global_position)
	var p = global_position.x - player.global_position.x
	#check that switch id match door id
	if _id == id:
		if not open:
			collision.disabled = true
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Door", self, {"ToggleDoor": 1, "DoorDistance": d, "DoorPan":p})
			visible = false
			open = true
		else:
			collision.disabled = false
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Door", self, {"ToggleDoor": 0, "DoorDistance": d, "DoorPan":p})
			visible = true
			open = false

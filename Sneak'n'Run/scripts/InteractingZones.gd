extends Node

onready var root = get_node("..")
onready var player = get_node("../Player")
onready var ui = get_node("../CanvasLayer/UI")

signal save


func _ready() -> void:
	var _c = connect("save", ui, "on_save")

#player makes noise when in sound zone
func _on_SoundZone_body_entered(body: Player) -> void:
	if not body:
		return
	Fmod.set_global_parameter_by_name("isInSoundZone", 1)
	player.is_in_sound_zone = true


func _on_SoundZone_body_exited(body: Player) -> void:
	if not body:
		return
	Fmod.set_global_parameter_by_name("isInSoundZone", 0)
	player.is_in_sound_zone = false


func _on_VictoryZone_body_entered(body: Player) -> void:
	if not body:
		return
	root.victory()


func _on_Checkpoint_body_entered(body: Player) -> void:
	if not body:
		return
	emit_signal("save")
	Globals.has_checked = true
	Globals.checkpoint_pos = Vector2(3360, 3008)


func _on_Checkpoint2_body_entered(body: Player) -> void:
	if not body:
		return
	emit_signal("save")
	Globals.has_checked = true
	Globals.checkpoint_pos = Vector2(4256, 3040)


func _on_Checkpoint3_body_entered(body: Player) -> void:
	if not body:
		return
	emit_signal("save")
	Globals.has_checked = true
	Globals.checkpoint_pos = Vector2(4160, 896)

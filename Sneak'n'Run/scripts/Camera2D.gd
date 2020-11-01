## Copyright (C) Antoine Pouille - All Rights Reserved
## Unauthorized copying of this file, via any medium is strictly prohibited
## Proprietary and confidential
## Written by Antoine Pouille <m.pouille.antoine@gmail.com>, September 2019

extends Camera2D

export var panel_size: Vector2 = Vector2(13 * 64, 9 * 64)

var panel: Vector2
var panel_pos: Vector2
var player_pos: Vector2

onready var player: Node2D = get_node("../Player")
onready var root: Node2D = get_node("..")


func _ready() -> void:
	update_panel(panel_of_pos(player.get_global_position()))


func _process(_delta: float) -> void:
	player_pos = player.get_global_position()
	var new_panel = panel_of_pos(player_pos)
	if new_panel != panel:
	  update_panel(new_panel)


func panel_of_pos(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / panel_size.x), floor(pos.y / panel_size.y))


func update_panel(new_panel: Vector2) -> void:
	panel = new_panel
	panel_pos = panel * panel_size
	position = panel_pos
	if root.state == root.ACTIVE:
		get_tree().call_group("ennemies", "wake_up")
		root.alert()


func is_on_panel(pos: Vector2, given_panel: Vector2) -> bool:
	return given_panel.x == floor(pos.x / panel_size.x) and given_panel.y == floor(pos.y / panel_size.y)


func is_on_current_panel(pos: Vector2) -> bool:
	return is_on_panel(pos, panel)

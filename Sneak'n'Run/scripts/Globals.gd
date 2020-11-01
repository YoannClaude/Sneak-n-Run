extends Node

var has_checked: bool
var checkpoint_pos: Vector2
var games: Dictionary = {"Sneak'n'Run": "res://tscn/Sneak'n'Run.tscn",
							"Tutorial": "res://tscn/Tutorial.tscn"}


func load_new_scene(new_scene_path: String) ->void :
	var _scene = get_tree().change_scene(new_scene_path)


func play(g: String) -> void:
    #simpler method to load scene using games dictionnary
	load_new_scene(games[g])

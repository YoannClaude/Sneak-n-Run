extends Control

class_name UIStart


func _ready():
    #fmod logo
	$Timer.start()


func _on_StartGame_pressed():
	Globals.load_new_scene(Globals.games["Tutorial"])


func _on_Quit_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	$TextureRect.visible = false
	$Panel/PauseMenu.visible = true

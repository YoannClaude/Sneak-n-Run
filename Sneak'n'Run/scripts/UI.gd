extends Control

class_name UI

onready var root: Node2D = get_node("../..")
onready var pause_menu: VBoxContainer = $Panel/PauseMenu
onready var sound_menu: VBoxContainer = $Panel/SoundMenu
onready var victory_menu: VBoxContainer = $Panel/VictoryMenu
onready var quit_screen: VBoxContainer = $Panel/Quit

var paused: bool


func _ready() -> void:
	self.visible = false
	get_tree().paused = false
	pause_mode = Node.PAUSE_MODE_PROCESS


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not paused:
			get_tree().paused = true
			self.visible = true
			pause_menu.visible = true
			paused = true
		else:
			Fmod.play_one_shot("event:/UI/Backward", self)
			resume()


func success() -> void:
	Fmod.stop()
	get_tree().paused = true
	victory_menu.visible = true
	self.visible = true


func resume() -> void:
	get_tree().paused = false
	Fmod.play_one_shot("event:/UI/Backward", self)
	self.visible = false
	pause_menu.visible = false
	sound_menu.visible = false
	paused = false


func on_save() -> void:
	$Panel.visible = false
	$GameSaved.visible = true
	self.visible = true
	yield(get_tree().create_timer(2.5), "timeout")
	self.visible = false
	$GameSaved.visible = false
	$Panel.visible = true
	

func _on_Resume__pressed():
	resume()


func _on_RestartGame_pressed():
	Fmod.play_one_shot("event:/UI/Forward", self)
	Globals.has_checked = false
	root.defeat()


func _on_Quit_pressed():
	$GameSaved.visible = false
	victory_menu.visible = false
	pause_menu.visible = false
	quit_screen.visible = true
	Fmod.shutdown()
	yield(get_tree().create_timer(2), "timeout")
	$Panel/Quit/Thanks.visible = false
	$Panel/Quit/Thanks2.visible = true
	yield(get_tree().create_timer(4), "timeout")
	$Panel/Quit/Thanks2.visible = false
	$Panel/Quit/Thanks3.visible = true
	yield(get_tree().create_timer(3), "timeout")
	get_tree().quit()


func _on_Options_pressed():
	Fmod.play_one_shot("event:/UI/Forward", self)
	pause_menu.visible = false
	sound_menu.visible = true


func _on_Back_pressed():
	Fmod.play_one_shot("event:/UI/Backward", self)
	pause_menu.visible = true
	sound_menu.visible = false


func _on_MusicVolume_value_changed(value):
	Fmod.set_bus_volume("bus:/Music", value)


func _on_SoundFXVolume_value_changed(value):
	Fmod.set_bus_volume("bus:/Ambient", value)
	Fmod.set_bus_volume("bus:/SoundFX", value)

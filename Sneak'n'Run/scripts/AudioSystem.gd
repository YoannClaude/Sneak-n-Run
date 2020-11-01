extends Node

var music
var siren
var ambient_passive
var guard_footsteps

func _enter_tree():
	# set up FMOD
	Fmod.set_software_format(0, Fmod.FMOD_SPEAKERMODE_STEREO, 0)
	Fmod.init(1024, Fmod.FMOD_STUDIO_INIT_LIVEUPDATE, Fmod.FMOD_INIT_NORMAL)
	Fmod.set_listener_number(2)
	
	#load banks
	var _b = Fmod.load_bank("res://addons/fmod/banks/Desktop/Master.strings.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	_b = Fmod.load_bank("res://addons/fmod/banks/Desktop/Master.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	_b = Fmod.load_bank("res://addons/fmod/banks/Desktop/Music.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	_b = Fmod.load_bank("res://addons/fmod/banks/Desktop/Ambient.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	_b = Fmod.load_bank("res://addons/fmod/banks/Desktop/SoundFX.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	_b = Fmod.load_bank("res://addons/fmod/banks/Desktop/UI.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	
	#set variables for events	
	music = Fmod.create_event_instance("event:/Music/MainSystem")
	siren = Fmod.create_event_instance("event:/Ambient/Siren")
	ambient_passive = Fmod.create_event_instance("event:/Ambient/AmbientPassive")
	guard_footsteps = Fmod.create_event_instance("event:/SoundFX/Ennemies/Guard/Footsteps")
	
	print("Fmod initialised.")


func start():
	#game should start with passive music loop
	Fmod.set_global_parameter_by_name("State", 0)
	Fmod.set_global_parameter_by_name("isPlaying", 0)
	Fmod.start_event(music)
	Fmod.start_event(ambient_passive)
 

func stop():
	#parameter used for music fade out
	Fmod.set_global_parameter_by_name("isPlaying", 1)


func alert():
	#check if siren is already on before playing 
	var state = Fmod.get_event_playback_state(siren)
	if state == 0:
		return
	Fmod.start_event(siren)

extends KinematicBody2D

class_name Switch

export var id: int = 0
export var timer_time: int 
var switchable: bool = false
var triggered: bool
var make_sound: bool

onready var root: Node2D = get_node("../../..")
onready var animation: AnimationPlayer = $AnimationPlayer
onready var sound_area: Area2D = $Sound
onready var timer: Timer = $Timer
onready var sound_timer: Timer = $SoundTimer


func _ready() -> void:
	sound_area.monitoring = false
	triggered = false
	if timer_time > 0:
		timer.wait_time = timer_time


func _process(_delta: float) -> void:
	update()


func _draw() -> void:
	if make_sound:
		draw_circle(global_position.normalized(), 250, Color(0.25, 0.41, 0.88, 0.15))


func trigger() -> void:
	if switchable:
		if not triggered:
			triggered = true
			make_sound = true
			sound_timer.start()
			sound_area.monitoring = true
			animation.play("Trigger")
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Switch", self, {"ToggleSwitch": 1})
			yield(get_tree().create_timer(0.7), "timeout")
			root._on_trigger(id)
			if timer_time > 0:
				timer.start()
		else:
			triggered = false
			sound_area.monitoring = true
			animation.play("Untrigger")
			Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Switch", self, {"ToggleSwitch": 0})
			yield(get_tree().create_timer(0.7), "timeout")
			root._on_trigger(id)
	yield(animation,"animation_finished")
	sound_area.monitoring = false


func untrigger() -> void:
	triggered = false
	sound_area.monitoring = true
	animation.play("Untrigger")
	Fmod.play_one_shot_with_params("event:/SoundFX/InteractingObjects/Switch", self, {"ToggleSwitch": 0})
	yield(get_tree().create_timer(0.7), "timeout")
	root._on_trigger(id)
	yield(animation,"animation_finished")
	sound_area.monitoring = false


func _on_Area2D_body_entered(body: Player) -> void:
	if not body:
		return
	switchable = true
	body.can_switch(true)


func _on_Area2D_body_exited(body: Player) -> void:
	if not body:
		return
	switchable = false
	body.can_switch(false)


func _on_Timer_timeout() -> void:
	timer.stop()
	if triggered:
		untrigger()


func _on_Sound_body_entered(body: KinematicBody2D) -> void:
	if triggered:
		body.hear_sound(global_position, global_position, "switch")


func _on_SoundTimer_timeout():
	make_sound = false

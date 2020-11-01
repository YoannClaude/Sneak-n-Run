extends KinematicBody2D

class_name Player
 
enum {STATIC, SNEAKING, WALKING, RUNNING, SHOOTING}

onready var root: Node2D = get_node("..")
onready var sound_radius = $Sound/CollisionShape2D.get_shape()
onready var animation_tree: AnimationTree = $AnimationTree
onready var playback = animation_tree.get("parameters/playback")
onready var sound_area: Area2D = $Sound
onready var timer: Timer = $Timer
onready var timer2: Timer = $Timer2

const pace: Array = [80,160,320]
var speed: int = pace[0]
const sound_level = [80, 250,300]
var noise: int = sound_level[0]
var is_moving: bool
var shoot: bool
var can_be_heard: bool
var stunned: bool
var is_in_sound_zone: bool
var can_hide: bool
var is_hidden: bool
var can_trigger: bool
var timer_running: bool
var timer2_running: bool
var hit_by_guard: bool
var aiming_at: Vector2
var velocity: Vector2
var last_dir: Vector2 = Vector2(0, 1)
var move: KinematicCollision2D
var action: String
var state

func _ready() -> void:
	if Globals.has_checked:
		position = Globals.checkpoint_pos
	state = STATIC


func _process(_delta: float) -> void:
	update()
	if stunned and not timer_running and not hit_by_guard:
		timer.start()
		timer_running = true
	if shoot and not timer2_running:
		timer2.start()
		timer2_running = true


func _physics_process(delta: float) -> void:
	if stunned or shoot or hit_by_guard:
		return
	get_input()
	if is_hidden:
		set_animation("idle", Vector2())
		return
	action = get_action()
	set_animation(action, last_dir)
	move = move_and_collide(velocity*delta)


func get_input() -> void:
	velocity = Vector2()
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	velocity = velocity.normalized() * speed

	if velocity == Vector2(0,0):
		is_moving = false
	else:
		last_dir = velocity
		is_moving = true

	if is_moving:
		if Input.is_action_pressed("fast"):
			speed = pace[2]
			can_be_heard = true
			if not is_in_sound_zone:
				noise = sound_level[1]
				make_sound(noise,true)
			else:
				noise = sound_level[2]
				make_sound(noise,true)
			state = RUNNING
		elif Input.is_action_pressed("slow"):
			speed = pace[0]
			can_be_heard = false
			make_sound(noise,false)
			state = SNEAKING
		else:
			state = WALKING
			speed = pace[1]
			if is_in_sound_zone:
				can_be_heard = true
				noise = sound_level[1]
				make_sound(noise,true)
			else:
				can_be_heard = true
				noise = sound_level[0]
				make_sound(noise,true)
	else:
		state = STATIC
		can_be_heard = false
		make_sound(noise,false)
		
	if Input.is_action_just_pressed("javelin"):
		aiming_at = (get_global_mouse_position()-global_position).normalized()
		state = SHOOTING
		shoot = true
		
	if Input.is_action_just_pressed("javelin_stick"):
		if not velocity == Vector2(0, 0):
			aiming_at = velocity.normalized()
		else:
			aiming_at = last_dir.normalized()
		state = SHOOTING
		shoot = true

	if Input.is_action_just_pressed("action"):
		if can_hide:
			root.last_player_pos = global_position
			visible = false
			is_hidden = true
			can_hide = false
			$CollisionShape2D.disabled = true
			Fmod.set_global_parameter_by_name("isHidden", 1)
		else:
			if is_hidden:
				visible = true
				is_hidden = false
				can_hide = true
				$CollisionShape2D.disabled = false
				Fmod.set_global_parameter_by_name("isHidden", 0)
		if can_trigger:
			get_tree().call_group("switch","trigger")

	if Input.is_action_just_pressed("pause"):
		Fmod.play_one_shot("event:/UI/Backward", self)


func get_action() -> String:
	match state:
		STATIC:
			return "idle"
		SNEAKING:
			return "sneak"
		WALKING:
			return "walk"
		RUNNING:
			return "run"
		SHOOTING:
			return "attack"
		_:
			return ""


func set_animation(act: String, vel: Vector2) -> void:
	if act == "attack":
		vel = aiming_at
	animation_tree.set("parameters/idle/blend_position", vel)
	animation_tree.set("parameters/sneak/blend_position", vel)
	animation_tree.set("parameters/walk/blend_position", vel)
	animation_tree.set("parameters/run/blend_position", vel)
	animation_tree.set("parameters/stunned/blend_position", vel)
	animation_tree.set("parameters/attack/blend_position", vel)
	animation_tree.set("parameters/defeat/blend_position", vel)
	var current_act
	if current_act == act:
		return
	current_act = act
	playback.travel(act)


func _draw() -> void:
	if not can_be_heard:
		return
	draw_circle(global_position.normalized(), noise, Color(0.25, 0.41, 0.88, 0.15))


func make_sound(radius, boolean) -> void:
	sound_area.monitoring = boolean
	sound_radius.set_radius(radius)



func play_sound() -> void:
	match state:
		WALKING:
			Fmod.play_one_shot_with_params("event:/SoundFX/Player/Footsteps", self, {"isRunning": 0})
		RUNNING:
			Fmod.play_one_shot_with_params("event:/SoundFX/Player/Footsteps", self, {"isRunning": 1})
		_:
			return


func _on_Sound_body_entered(body) -> void:
	if not body.is_in_group("ennemies"):
		return
	body.hear_sound(global_position, global_position, "player")


func attack() -> void:
	root.javelin(aiming_at, global_position)
	Fmod.play_one_shot("event:/SoundFX/Player/Shot", self)


func can_switch(boolean: bool) -> void:
	can_trigger = boolean


func spell_hit() -> void:
	if hit_by_guard:
		return
	stunned = true
	set_animation("stunned", last_dir)


func guard_hit() -> void:
	set_animation("defeat", last_dir)
	stunned = true
	hit_by_guard = true


func _on_Timer_timeout():
	stunned = false
	timer_running = false


func _on_Timer2_timeout():
	shoot = false
	timer2_running = false

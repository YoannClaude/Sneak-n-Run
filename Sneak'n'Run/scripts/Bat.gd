extends Ennemies

class_name Bat

onready var collision_shape: CollisionShape2D = $CollisionShape2D

const speed: int = 280

var move_speed: float
var move: KinematicCollision2D


func _ready() -> void:
	#randomize bat speed
	rng = RandomNumberGenerator.new()
	rng.randomize()
	random_speed_mod = rng.randf_range(0.75, 1)
	move_speed = speed * random_speed_mod
	#game starts with bats sleeping
	state = STATIC
	animation_tree.set("parameters/idle/blend_position", Vector2(0,1))


func _physics_process(delta: float) -> void:
	if stunned:
		return
	action = get_action()
	if state == STATIC:
		return
	set_animation(velocity, action)
	set_movement(delta)


func get_action() -> String:
	#return string in order to set animation
	match state:
		STATIC:
			return idle()
		CHASING:
			return chase_player()
		_:
			return ""


func idle() -> String:
	velocity = Vector2()
	return "idle"
	

func chase_player():
	velocity = (player.global_position - global_position).normalized() * move_speed
	return "attack"


func set_animation(vel: Vector2, act: String) -> void:
	#set animation with direction and action
	animation_tree.set("parameters/idle/blend_position", vel)
	animation_tree.set("parameters/attack/blend_position", vel)
	animation_tree.set("parameters/stunned/blend_position", vel)
	var current_act
	if current_act == act:
		return
	current_act = act
	playback.travel(act)


func set_movement(d: float) -> void:
	move = move_and_collide(velocity * d)


func is_stunned() -> void:
	stunned = true
	play_sound("stunned")
	state = STATIC
	collision_shape.disabled = true
	z_index = 1
	set_animation(velocity, "stunned")
	root.last_player_pos = player.global_position


func wake_up() -> void:
	if camera.is_on_current_panel(global_position):
		collision_shape.disabled = false
		stunned = false
		z_index = 3
		state = CHASING


func hear_sound(_s: Vector2, _s2:Vector2, _s3: String) -> void:
	pass


func play_sound(event: String) -> void:
	if not visnot.is_on_screen():
		return
	var d = global_position.distance_to(player.global_position)
	var p = global_position.x - player.global_position.x
	match event:
		"wings":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Bat/Wings", self, {"BatDistance": d, "BatPan": p})
		"stunned":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Bat/Stunned", self, {"BatDistance": d, "BatPan": p})

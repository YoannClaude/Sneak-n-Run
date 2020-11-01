extends Ennemies

class_name Priest

export (String, "clockwise", "counter-clockwise", "none") var rotate

onready var timer: Timer = $Timer
onready var rotate_timer: Timer = $RotateTimer

var rotate_timer_running: bool
var timer_running: bool
var last_dir


func _ready() -> void:
	state = STATIC


func _process(_delta: float) -> void:
	update()


func _physics_process(_delta: float) -> void:
	if stunned or surprised:
		return
	action = get_action()
	set_animation(velocity, action)


func get_action() -> String:
	match state:
		STATIC:
			return idle()
		INVOQUING:
			return invoque()
		CASTING:
			return cast()
		_:
			return""


func set_animation(vel: Vector2, act: String) -> void:
	if act == "idle":
		vel = facing_dir.get(facing)
	animation_tree.set("parameters/idle/blend_position", vel)
	animation_tree.set("parameters/cast/blend_position", vel)
	animation_tree.set("parameters/stunned/blend_position", vel)
	animation_tree.set("parameters/invoque/blend_position", vel)
	var current_act
	if current_act == act:
		return
	current_act = act
	playback.travel(act)


func _draw() -> void:
	if stunned or not state == STATIC or not visnot.is_on_screen():
		return
	var color: Color = Color(0.68, 0.85, 0.9, 0.03)
	if surprised:
		color = Color(1,0,0,0.07)
	match last_dir:
		"Down":
			points = [pt0, pt1["Down"], pt2["Down"], pt3["Down"]]
		"Up":
			points = [pt0, pt1["Up"], pt2["Up"], pt3["Up"]]
		"Left":
			points = [pt0, pt1["Left"], pt2["Left"], pt3["Left"]]
		"Right":
			points = [pt0, pt1["Right"], pt2["Right"], pt3["Right"]]
	for _i in range(point_nb):
		draw_colored_polygon(points, color)


func idle() -> String:
	if not rotate_timer_running and not rotate == "none":
		rotate_timer.start()
		rotate_timer_running = true
	last_dir = facing
	velocity = Vector2()
	return "idle"
	
	
func cast() -> String:
	return "cast"


func invoque() -> String:
	velocity = (player.global_position - global_position).normalized()
	state = INVOQUING
	if not timer_running:
		timer_running = true
		timer.start()
	return "invoque"


func _on_Timer_timeout() -> void:
	state = CASTING
	play_sound("cast")
	root.cast(global_position)
	timer_running = false


func wake_up() -> void:
	if camera.is_on_current_panel(global_position):
		if state == STATIC:
			rotate_timer.stop()
			rotate_timer_running = false
			stunned = false
			is_surprised(player.global_position, INVOQUING)
		else:
			return
	else:
		state = STATIC


func hear_sound(source: Vector2, _s2:Vector2, _s3: String) -> void:
	if stunned or not state == STATIC:
		return
	if camera.is_on_current_panel(global_position) and state == STATIC:
		is_surprised(source, INVOQUING)


func is_surprised(pos: Vector2, act) -> void:
	if not rotate == "none":
		rotate_timer.stop()
	surprised = true
	velocity = Vector2()
	var action: String = playback.get_current_node()
	last_dir = get_direction(pos - global_position)
	animation_tree.set("parameters/"+action+"/blend_position", (pos - global_position).normalized())
	yield(get_tree().create_timer(0.4, false), "timeout")
	state = act
	root.last_player_pos = player.global_position
	get_tree().call_group("ennemies", "wake_up")
	surprised = false


func _on_Vision_cone_body_entered(body: Player) -> void:
	if stunned:
		return
	if body and state == STATIC:
		is_surprised(player.global_position, INVOQUING)


func is_stunned() -> void:
	if not rotate == "none":
		rotate_timer.stop()
	set_animation(velocity, "stunned")
	stunned = true
	state = STATIC
	play_sound("stunned")
	root.last_player_pos = player.global_position


func _on_RotateTimer_timeout() -> void:
	match rotate:
		"clockwise":
			match last_dir:
				"Down":
					facing = "Left"
				"Left":
					facing = "Up"
				"Up":
					facing = "Right"
				"Right":
					facing = "Down"
		"counter-clockwise":
			match last_dir:
				"Down":
					facing = "Right"
				"Left":
					facing = "Down"
				"Up":
					facing = "Left"
				"Right":
					facing = "Up"
	rotate_timer_running = false


func play_sound(event: String) -> void:
	if not visnot.is_on_screen():
		return
	var d = global_position.distance_to(player.global_position)
	var p = global_position.x - player.global_position.x
	match event:
		"cast":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Priest/Cast", self, {"PriestDistance": d, "PriestPan": p})
		"stunned":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Priest/Stunned", self, {"PriestDistance": d, "PriestPan": p})

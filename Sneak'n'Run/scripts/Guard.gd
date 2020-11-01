extends Ennemies

class_name Guard

export (NodePath) var patrol_path

var speed: Array = [50,120,190]
var move_speed: Array
var patrol_points: Array
var patrol_index: int = 0
var path: Array
var target: Vector2
var static_pos: Vector2
var move: KinematicCollision2D
var see: KinematicBody2D
var sound_source: Vector2 = Vector2()
var sound_source_origin: Vector2 = Vector2()
var static_guard: bool
var switch_target: Switch
var trap_pos: Vector2
var last_dir
var is_attacking: bool


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	random_speed_mod = rng.randf_range(0.75, 1)
	move_speed = [speed[0] * random_speed_mod, speed[1] * random_speed_mod, speed[2] * random_speed_mod]
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
		state = PATROLING
		return
	state = STATIC
	static_guard = true
	static_pos = global_position


func _process(_delta: float) -> void:
	update()
	if stunned or state == TRAPPED:
		return
	if see and not state == CHASING:
		check_vision(see)
	
	
func _draw() -> void:
	if stunned or surprised or not visnot.is_on_screen() or state == CHASING:
		return
	var color: Color
	match state:
		STATIC:
			color = Color(0.68, 0.85, 0.9, 0.03)
		PATROLING:
			color = Color(0.68, 0.85, 0.9, 0.03)
		SUSPICIOUS:
			color = Color(1, 1, 0, 0.03) 
		LOOKING:
			color = Color(1, 1, 0, 0.03)
		GETTING_CALM:
			color = Color(0.68, 0.85, 0.9, 0.03)
		TRAPPED:
			return
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


func check_vision(body: KinematicBody2D) -> void:
	var space_tate = get_world_2d().direct_space_state
	var target_extents = body.get_node("CollisionShape2D").shape.extents - Vector2(5,5)
	var c1 = body.global_position - target_extents
	var c2 = body.global_position + target_extents
	var c3 = body.global_position + Vector2(target_extents.x, -target_extents.y)
	var c4 = body.global_position + Vector2(-target_extents.x, +target_extents.y)
	for pos in [c1, c2, c3, c4]:
		var result: Dictionary = space_tate.intersect_ray(global_position, pos,
					 [self], collision_mask)
		if result:
			if result.collider is Player:
				if result.collider.is_hidden:
					return
				if not surprised:
					is_surprised(player.global_position, CHASING)
				break
			elif result.collider is Switch:
				if not result.collider.triggered:
					return
				var switches: Array = get_tree().get_nodes_in_group("switch")
				for i in range (switches.size()):
					if camera.is_on_current_panel(switches[i].global_position):
						switch_target = switches[i]
						target = switches[i].global_position
						break
				sound_source = navigation.get_closest_point(target)
				state = SUSPICIOUS
				break
			else:
				break


func _physics_process(delta: float) -> void:
	if surprised:
		return
	action = get_action()
	set_animation(velocity, action)
	if state == LOOKING or STATIC:
		return
	set_movement(delta)


func get_action() -> String:
	match state:
		STATIC:
			return idle()
		PATROLING:
			return patrol()
		SUSPICIOUS:
			return investigate()
		CHASING:
			return chase_player()
		LOOKING:
			return look_around()
		GETTING_CALM:
			return go_back_home()
		TRAPPED:
			return fall_in_trap()
		_:
			return ""


func idle() -> String:
	velocity = Vector2()
	return "idle"


func patrol() -> String:
	target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - global_position).normalized() * move_speed[0]
	return "patrol"


func investigate() -> String:
	path = navigation.get_simple_path(global_position, sound_source, true)
	if position.distance_to(path[0]) < 1:
		path.remove(0)
	velocity = (path[0] - global_position).normalized() * move_speed[1]
	if position.distance_to(sound_source) < 1:
		if switch_target:
			switch_target.untrigger()
			switch_target = null
			return "investigate"
		elif not sound_source_origin == Vector2():
			sound_source = sound_source_origin
			sound_source_origin = Vector2()
			return "investigate"
		state = LOOKING
	return "investigate"


func chase_player() -> String:
	if not player.is_hidden:
		path = navigation.get_simple_path(global_position, player.global_position, true)
		if position.distance_to(path[0]) < 1:
			path.remove(0)
		velocity = (path[0] - global_position).normalized() * move_speed[2]
	else:
		root.set_last_player_pos()
		state = SUSPICIOUS
	return "chase"


func look_around() -> String:
	velocity = Vector2()
	return "look_around"


# draw method follows look_around animation
func set_dir(dir: String) -> void: 
	last_dir = dir


func go_back_home() -> String:
	if static_guard:
		path = navigation.get_simple_path(global_position, static_pos, true)
		if position.distance_to(path[0]) < 1:
			path.remove(0)
		velocity = (path[0] - global_position).normalized() * move_speed[0]
		if position.distance_to(static_pos) < 1:
			state = STATIC
	else:
		path = navigation.get_simple_path(global_position, patrol_points[0], true)
		if position.distance_to(path[0]) < 1:
			path.remove(0)
		velocity = (path[0] - global_position).normalized() * move_speed[0]
		if position.distance_to(patrol_points[0]) < 1:
			state = PATROLING
	return "patrol"


func fall_in_trap() -> String:
	path = navigation.get_simple_path(global_position, trap_pos, true)
	if position.distance_to(path[0]) < 1:
		path.remove(0)
	velocity = (path[0] - global_position).normalized() * move_speed[0]
	return "fall_in_trap"


func set_animation(vel: Vector2, action: String) -> void:
	if not action == "idle":
		last_dir = get_direction(velocity)
	else:
		last_dir = facing
		vel = facing_dir.get(facing)
	animation_tree.set("parameters/idle/blend_position", vel)
	animation_tree.set("parameters/patrol/blend_position", vel)
	animation_tree.set("parameters/investigate/blend_position", vel)
	animation_tree.set("parameters/chase/blend_position", vel)
	animation_tree.set("parameters/look_around/blend_position", vel)
	animation_tree.set("parameters/stunned/blend_position", vel)
	animation_tree.set("parameters/attack/blend_position", vel)
	var current_act
	if current_act == action:
		return
	current_act = action
	playback.travel(action)


func set_movement(d: float) -> void:
	move = move_and_collide(velocity * d)
	if move:
		if move.collider is Player:
			if not state == CHASING and not surprised:
				is_surprised(player.global_position, CHASING)
				return
			set_animation(velocity, "attack")
			player.guard_hit()


func _on_Vision_cone_body_entered(body: KinematicBody2D) -> void:
	if not camera.is_on_current_panel(global_position):
		return
	see = body


func _on_Vision_cone_body_exited(body: Player) -> void:
	if not body:
		return
	see = null
	root.last_player_pos = body.get_global_position()


func hear_sound(source: Vector2, source_origin: Vector2, name: String) -> void:
	if state == CHASING or not camera.is_on_current_panel(global_position):
		return
	if name == "javelin":
		sound_source_origin = navigation.get_closest_point(source_origin)
	sound_source = navigation.get_closest_point(source)
	if not surprised:
		is_surprised(sound_source, SUSPICIOUS)


func is_surprised(pos: Vector2, act) -> void:
	surprised = true
	velocity = Vector2()
	var action: String = playback.get_current_node()
	last_dir = get_direction(pos - global_position)
	animation_tree.set("parameters/"+action+"/blend_position", (pos - global_position).normalized())
	yield(get_tree().create_timer(0.4, false), "timeout")
	state = act
	if state == CHASING:
		get_tree().call_group("ennemies", "wake_up")
	surprised = false


func is_stunned() -> void:
	stunned = true
	play_sound("stunned")
	set_animation(velocity, "stunned")
	yield(get_tree().create_timer(1.0, false), "timeout")
	stunned = false


func wake_up() -> void:
	if camera.is_on_current_panel(global_position) and not state == CHASING:
		is_surprised(player.global_position, CHASING)


func getting_calm() -> void:
	state = GETTING_CALM


func attack() -> void:
	is_attacking = true
	root.defeat()
	play_sound("attack")


func get_trapped(pos: Vector2) -> void:
	trap_pos = pos
	state = TRAPPED


func disappear() -> void:
	queue_free()


func play_sound(event: String) -> void:
	if not visnot.is_on_screen():
		return
	var d = global_position.distance_to(player.global_position)
	var p = global_position.x - player.global_position.x
	match event:
		"attack":
			Fmod.play_one_shot("event:/SoundFX/Ennemies/Guard/Attack", self)
		"stunned":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Guard/Stunned", self, {"GuardDistance": d, "GuardPan": p})
		"footsteps":
			Fmod.play_one_shot_with_params("event:/SoundFX/Ennemies/Guard/Footsteps", self, {"GuardDistance": d, "GuardPan": p})

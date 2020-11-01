extends KinematicBody2D

class_name Javelin

onready var root = get_node("..")
onready var timer:Timer = $Timer
onready var player: Player = get_node("../Player")

const speed: int = 2000
var make_sound: bool
var dir: Vector2
var velocity: Vector2
var init_pos: Vector2


func init(aiming_at: Vector2, pos: Vector2) -> void:
    #set position and direction
	position = pos
	init_pos = pos
	dir = aiming_at
	velocity = aiming_at.normalized()
	set_rotation(aiming_at.angle())

func _process(_delta: float) -> void:
	if make_sound:
		update()


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity*speed*delta)
	if collision:
		set_deferred("make_sound", true)
		$Sound.monitoring = true
		timer.start()
		if collision.collider.is_in_group("tiles"):
            #set vol and pan of sound fx based on distance and position from player
			var d: float = global_position.distance_to(player.global_position)
			var p: float = global_position.x - player.global_position.x
			Fmod.play_one_shot_with_params("event:/SoundFX/Player/Javelin", self, {"JavelinDistance":d, "JavelinPan":p})
		if collision.collider is Ennemies:
			collision.collider.is_stunned()
		set_physics_process(false)


func _draw() -> void:
	if make_sound:
		draw_circle(global_position.normalized(), 250, Color(0.25, 0.41, 0.88, 0.15))


func _on_Sound_body_entered(body: KinematicBody2D) -> void:
	if body is Ennemies:
		body.hear_sound(get_global_position(), init_pos, "javelin")


func _on_Timer_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

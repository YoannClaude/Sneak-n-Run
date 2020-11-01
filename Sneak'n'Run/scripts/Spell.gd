extends KinematicBody2D

class_name Spell

onready var player: Player = get_node("../Player")

const speed: int = 1000

var has_played: bool = false
var spell_sound


func init(pos: Vector2) -> void:
	position = pos
	spell_sound = Fmod.create_event_instance("event:/SoundFX/Ennemies/Priest/Spell")


func _process(delta: float) -> void:
	if !has_played:
		Fmod.start_event(spell_sound)
		has_played = true
	var d = global_position.distance_to(player.global_position)
    #set volume and pan of sound fx based on distance and position from player
	if d < 790:
		Fmod.set_event_parameter_by_name(spell_sound, "SpellDistance", d)
	var p = global_position.x - player.global_position.x
	Fmod.set_event_parameter_by_name(spell_sound, "SpellPan", p)
	var collision = move_and_collide((player.global_position-global_position).normalized()*speed*delta)
	if collision:
		if collision.collider is Player:
			player.spell_hit()
			Fmod.release_event(spell_sound)
		queue_free()

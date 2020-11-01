extends Light2D

onready var root: Node2D = get_node("../..")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")


func _ready() -> void:
	energy = 0


func lights_off() -> void:
	animation.play("off")


func lights_on() -> void:
	animation.play("on")


func lights_red() -> void:
	animation.play("red")

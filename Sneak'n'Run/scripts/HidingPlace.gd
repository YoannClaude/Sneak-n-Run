extends KinematicBody2D

class_name HidingPlace


func _on_Area2D_body_entered(body: Player) -> void:
	if not body:
		return
	body.can_hide = true


func _on_Area2D_body_exited(body: Player) -> void:
	if not body:
		return
	body.can_hide = false

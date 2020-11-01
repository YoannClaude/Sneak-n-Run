extends Control

var trigger: bool

#script to manage tutorial messages

func _on_Move_body_entered(body:Player):
	if not body:
		return
	$Move.visible = true
	$Run.visible = false


func _on_Run_body_entered(body: Player):
	if not body:
		return
	$Run.visible = true
	$Move.visible = false
	$Sneak.visible = false


func _on_Sneak_body_entered(body: Player):
	if not body:
		return
	$Sneak.visible = true
	$Run.visible = false
	$Shoot.visible = false


func _on_Shoot_body_entered(body: Player):
	if not body:
		return
	$Shoot.visible = true
	$Sneak.visible = false
	$Hide.visible = false
	if trigger:
		return
	get_tree().call_group("ennemies", "wake_up")
	trigger = true


func _on_Hide_body_entered(body: Player):
	if not body:
		return
	$Hide.visible = true
	$Shoot.visible = false
	$Toggle.visible = false


func _on_Toggle_body_entered(body: Player):
	if not body:
		return
	$Toggle.visible = true
	$Hide.visible = false


func hide_toggle() -> void:
	$Toggle.visible = false

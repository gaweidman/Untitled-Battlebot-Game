@icon("res://graphics/images/class_icons/botDeath.png")
extends Area3D

class_name DeathPlane
## Kills any [Combatant] or [Robot] who dare enter.

func _on_body_entered(body):
	if body.get_parent() is Combatant:
		body.get_parent().die();
	if body is RobotBody:
		body.get_parent().die();
	pass # Replace with function body.

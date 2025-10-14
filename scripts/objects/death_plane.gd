extends Area3D

class_name DeathPlane



func _on_body_entered(body):
	if body.get_parent() is Combatant:
		body.get_parent().die();
	if body is RobotBody:
		body.get_parent().die();
	pass # Replace with function body.

extends PartActiveProjectile

class_name PartSniper

func _activate():
	if super():
		thisBot.take_knockback((firingAngle * -400) + Vector3(0,200,0))

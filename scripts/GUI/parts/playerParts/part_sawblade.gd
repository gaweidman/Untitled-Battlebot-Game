extends PartActiveMelee

class_name PartSawblade

var modelScaleOffset := Vector3.ONE;
var baseRotationSpeed := 180.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;

func contact_damage(collider: Node) -> void:
	var par = collider.get_parent();
	if par is Combatant && par != thisBot:
		# https://www.youtube.com/watch?v=7s0nIxBLZio
		#if ! par.combatHandler.invincible:
		
		par.combatHandler.take_damage(damage);
		# i'm trying to make the knockback a function of how fast each 
		# collider is going
		
		#var distanceDif = par.body.global_position - thisBot.body.global_position;
		#par.take_knockback((distanceDif + Vector3(0,0.01,0)) * 1000);
		#thisBot.take_knockback((-distanceDif + Vector3(0,0.01,0)) * 1000);
		
		var distanceDif = par.body.global_position - thisBot.body.global_position;
		var parVelocity = par.get_node("Body").linear_velocity;
		var thisbotVelocity = thisBot.get_node("Body").linear_velocity;
		
		var parDirection = parVelocity.normalized();
		var thisbotDirection = thisbotVelocity.normalized();
		
		var parSpeed = parVelocity.length();
		var thisbotSpeed = thisbotVelocity.length();
		
		print("PARSPEED ", parSpeed, " ", thisbotSpeed)
		
		par.take_knockback(thisbotVelocity * 100000 + Vector3(0,0.01,0) * 1000000);
		thisBot.take_knockback(parVelocity * 100000 + Vector3(0,0.01,0) * 1000000);
		
		par.get_node("Body").apply_central_force(Vector3(10000, 0, 0))
		
		#print("Damage dealt: ", damage)
		pass;
	else:
		return;

func _process(delta):
	super(delta);
	#modelScaleOffset += Vector3(1,1,1) * delta
	modelScaleOffset = lerp(modelScaleOffset, Vector3.ONE, delta * 10);
	rotationSpeed = lerp(rotationSpeed, baseRotationSpeed, delta * 4);
	damageModifier = lerp(damageModifier, 1.0, delta * 10);
	meshNode.set_deferred("scale", modelScale * modelScaleOffset);
	weaponNode.set_deferred("scale", modelScaleOffset * Vector3.ONE);
	add_rotation(rotationSpeed * delta);
	$ShapeCast3D.set_deferred("global_position", thisBot.body.global_position)
	
	##Deflect bullets 
	if $ShapeCast3D.is_colliding():
		for item in $ShapeCast3D.collision_result:
			if item.collider is Bullet:
				
				var bullet = item.collider;
				if bullet.get_attacker() != thisBot:
					thisBot.call_deferred("take_knockback",(bullet.dir + Vector3(0,0.01,0)) * 1000);
					var dir = bullet.dir * -1;
					bullet.change_direction(dir);
					bullet.set_attacker(thisBot);

func _activate():
	super();
	modelScaleOffset *= 2;
	rotationSpeed *= 3;
	$ShapeCast3D.enabled = true;
	$Timer.start();
	damageModifier *= 3;

func _rotate_with_player():
	super();
	meshNode.rotation += Vector3(0,deg_to_rad(rotationDeg),0);

func add_rotation(deg):
	rotationDeg += deg;
	if deg >= 360:
		deg -= 360;

func _on_timer_timeout():
	$ShapeCast3D.enabled = false;
	pass # Replace with function body.

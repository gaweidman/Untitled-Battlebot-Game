extends PartActiveMelee

class_name PartSawblade

var modelScaleOffset := Vector3.ONE;
var baseRotationSpeed := 180.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;

func contact_damage(collider: Node) -> void:
	super(collider);
	if equipped:
		var par = collider.get_parent();
		if par != thisBot:
			if par is Combatant:
				##Particles!!!
				var particlePos = Vector3(randf_range(0.25,-0.25), 0, randf_range(0.25,-0.25))
				particlePos += (positionNode.global_position + par.body.global_position) / 2
				ParticleFX.play("Sparks", GameState.get_game_board(), particlePos)
				
				#if ! par.combatHandler.invincible:
				par.combatHandler.take_damage(get_damage());
				var distanceDif = par.body.global_position - thisBot.body.global_position;
				var thatBotVelocity = par.body.linear_velocity;
				var thisBotVelocity = thisBot.body.linear_velocity;
				par.take_knockback(((distanceDif + Vector3(0,0.1,0)) * 1000) + thisBotVelocity - thatBotVelocity);
				thisBot.body.linear_velocity = Vector3(thisBotVelocity.x * -1, thisBotVelocity.y, thisBotVelocity.z * -1)
				thisBot.take_knockback(((-distanceDif + Vector3(0,0.1,0)) * 1000) - thisBotVelocity + thatBotVelocity);
				modelScaleOffset /= 1.5;
				#print("Damage dealt: ", damage)
				pass;
			else:
				return;
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
				print(item)
				var bullet = item.collider;
				if bullet.get_attacker() != thisBot:
					thisBot.call_deferred("take_knockback",(bullet.dir + Vector3(0,0.1,0)) * 1000);
					var dir = bullet.dir * -1;
					bullet.change_direction(dir);
					bullet.set_attacker(thisBot);
					
					##Particles!!!
					var particlePos = Vector3(randf_range(0.1,-0.1), 0, randf_range(0.1,-0.1))
					particlePos += item.point
					ParticleFX.play("Sparks", GameState.get_game_board(), particlePos)
	

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

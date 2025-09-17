extends PartActiveMelee

class_name PartSawblade

var modelScaleOffset := Vector3.ONE;
@export var baseRotationSpeed := 270.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;
@export var sawSoundPlayer : AudioStreamPlayer3D;
var sawSoundVolume := 0.0;
var sawSoundPitch := 1.0;
var snd : SND;

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

func _physics_process(delta):
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
				#print(item)
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
					SND.play_sound_at("Weapon.Sawblade.Parry", particlePos, GameState.get_game_board(), 1.0, 0.5);
	
	if ! is_instance_valid(snd):
		snd = SND.get_physical();
	else:
		if is_instance_valid(sawSoundPlayer):
			sawSoundPitch = lerp(sawSoundPitch, 0.8, delta * 4);
			if GameState.get_setting("sawbladeDrone") == true:
				var playerInRange = GameState.is_player_in_range(%Weapon.global_position, 80.0);
				if get_equipped() && meshNode.visible == true && playerInRange:
					var lenToPlayer = GameState.get_len_to_player(%Weapon.global_position);
					#print( * 0.8)
					var volume = ((80.0 - lenToPlayer) / 80.0)
					#print(volume)
					var maxVolume := 0.70;
						
					if thisBot is Player:
						maxVolume = 0.40;
					sawSoundVolume = lerp(sawSoundVolume, volume * maxVolume, delta * 3);
					#sawSoundPlayer.stream_paused = false;
				else:
					sawSoundVolume = lerp(sawSoundVolume, 0.0, delta * 6);
			else:
				sawSoundVolume = lerp(sawSoundVolume, 0.0, delta * 3);
					#sawSoundPlayer.stream_paused = true;
			sawSoundPlayer.volume_db = linear_to_db(sawSoundVolume * SND.get_volume_world());
			sawSoundPlayer.pitch_scale = sawSoundPitch;

func _activate():
	if super():
		modelScaleOffset *= 2;
		rotationSpeed *= 3;
		$ShapeCast3D.enabled = true;
		$Timer.start();
		damageModifier *= 3;
		sawSoundPitch = 0.9;
		sawSoundVolume = 1.0;
		thisBot.combatHandler.add_invincibility(0.25);
	#if is_instance_valid(sawSoundPlayer):
		#sawSoundPlayer.play();

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

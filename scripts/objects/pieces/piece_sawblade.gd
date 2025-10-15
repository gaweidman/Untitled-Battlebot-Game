extends Piece

class_name Piece_Sawblade

@export var baseRotationSpeed := 270.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;
@export var sawSoundPlayer : AudioStreamPlayer3D;
var sawSoundVolume := 0.0;
var sawSoundPitch := 1.0;
var snd : SND;
var hitboxScaleOffset := 1.0;
var bladeScaleOffset := 1.0;
var bladeScaleBase := 0.713;

var reflectingBullets := false;
var reflectingTime := 0;

@export var blade : MeshInstance3D;

func stat_registry():
	super();

func add_rotation(deg):
	rotationDeg += deg;
	if deg >= 360:
		deg -= 360;

func ability_registry():
	register_active_ability("Deflect", "Spin the sawblade with extreme speed, causing it to deflect projectiles and deal extra damage.", func (): deflect())

func phys_process_timers(delta):
	super(delta);
	bladeScaleOffset = lerp(bladeScaleOffset, 1.0, delta * 12) 
	if reflectingTime > 0:
		reflectingTime -= 1;
	else:
		hitboxScaleOffset = lerp(hitboxScaleOffset, 1.0, delta * 12) 
	reflectingBullets = hitboxScaleOffset > 1.1;
	damageModifier = lerp(damageModifier, 1.0, delta * 12)

func phys_process_collision(delta):
	super(delta);
	#if get_cooldown_active() > 0:
		##var maxCooldown = get_stat("CooldownActive");
		##var curCooldown = get_cooldown_active();
		##var ratio = curCooldown / maxCooldown;
		##hitboxCollisionHolder.scale
	hitboxCollisionHolder.scale = Vector3.ONE * hitboxScaleOffset;
	#else:
		#hitboxCollisionHolder.scale = Vector3.ONE;

func phys_process_abilities(delta):
	super(delta);
	if can_use_passive() and not on_cooldown():
		rotationSpeed = lerp(rotationSpeed, baseRotationSpeed, delta * 4);
		pass;
	else:
		rotationSpeed = lerp(rotationSpeed, 0.0, delta * 4);
		damageModifier = 0.0;
		pass;
	add_rotation(rotationSpeed * delta);

func process_draw(delta):
	super(delta);
	blade.rotation.y = deg_to_rad(rotationDeg);
	blade.scale = Vector3.ONE * bladeScaleOffset * bladeScaleBase;

func contact_damage(otherPiece : Piece, otherPieceCollider : PieceCollisionBox, thisPieceCollider : PieceCollisionBox):
	if can_use_passive():
		if super(otherPiece, otherPieceCollider, thisPieceCollider):
			#print("HUzzah!")
			set_cooldown_passive();
			bladeScaleOffset /= 1.5;
		else:
			#print_rich("[color=orange]Sawblade tried to do contact damage, but is on passive cooldown for ",get_cooldown_passive()," seconds.")
			pass;
	else:
		#print_rich("[color=orange]Sawblade tried to do contact damage, but is unable to use its passive.")
		pass;
	pass;

#func cooldown_behavior_active(onCooldown : bool = on_cooldown_active()):
	#hitboxCollisionHolder.scale.lerp(Vector3.ONE * bladeScaleOffset, get_physics_process_delta_time() * 12)
	#pass;
#
#
#func cooldown_behavior_passive(onCooldown : bool = on_cooldown_passive()):
	#hitboxCollisionHolder.scale.lerp(Vector3.ONE * bladeScaleOffset, get_physics_process_delta_time() * 12)
	#pass;

func cooldown_behavior(onCooldown : bool = on_cooldown()):
	#if onCooldown:
		#
		#return;
	if on_cooldown_active():
		hitboxCollisionHolder.scale.lerp(Vector3.ONE * bladeScaleOffset, get_physics_process_delta_time() * 12)
		return;
	if on_cooldown_passive():
		#bladeScaleOffset = 0.5;
		hitboxCollisionHolder.scale.lerp(Vector3.ONE * 0.5, get_physics_process_delta_time() * 12)
		return;
	pass;

func deflect():
	bladeScaleOffset *= 1.75;
	hitboxScaleOffset *= 2.5;
	reflectingTime = 5;
	rotationSpeed *= 3;
	#$ShapeCast3D.enabled = true;
	#$Timer.start();
	damageModifier *= 3;
	sawSoundPitch = 0.9;
	sawSoundVolume = 1.0;
	get_host_robot().set_invincibility(0.25);
	pass;

func bullet_hit_hitbox(bullet:Bullet):
	##TODO: Add enemies so this can actually be tested. Lol.
	if bullet.get_attacker() != get_host_robot():
		print_rich("[color=orange]Bullet hit the hitbox.")
	if reflectingBullets:
		if bullet.get_attacker() != get_host_robot():
			#var posDif = global_position - bullet.global_position;
			#bullet.flip_direction();
			#bullet.set_attacker(get_host_robot())
			reflectingTime += 2;
			var thisBot = get_host_robot();
			thisBot.call_deferred("take_knockback",(bullet.dir + Vector3(0,0.1,0)) * 1000);
			var dir = bullet.dir * -1;
			bullet.change_direction(dir);
			bullet.set_attacker(thisBot);
			bullet.verticalVelocity = 0.1;
			
			##Particles!!!
			var particlePos = Vector3(randf_range(0.1,-0.1), 0, randf_range(0.1,-0.1))
			particlePos += bullet.global_position
			ParticleFX.play("Sparks", GameState.get_game_board(), particlePos)
			SND.play_sound_at("Weapon.Sawblade.Parry", particlePos, GameState.get_game_board(), 1.0, 0.5);

extends Piece

class_name Piece_Projectile

@export_subgroup("Bullet Stuff")
@export var bulletRef : PackedScene = preload("res://scenes/prefabs/objects/bullets/bullet.tscn");
var magazine : Array[Bullet] = [];
var magazineCount := 0;
##The base max amount of bullets in the magazine.
@export var magazineMaxBase := 3;
@export var magazineRefreshRate := 6.0;
##The base speed to launch fired projectiles.
@export var launchSpeed := 30.0;
@export var fireRate := 0.5;
##Calculated.
var firingAngle := Vector3.BACK;

@export_subgroup("Range and Timing")
##The raycast used when enemies use this Piece.
@export var rangeRay : RayCast3D;
##How long a projectile lasts after being fired.
@export var bulletLifetime := 1.0;
##An inaccuracy added to its firing.
@export var inaccuracy := 0.05;
var fireRateTimer := 0.0;

##How much acceleration on the Y axis projectiles shot by this recieve.
@export var bulletGravity := -0.0987;
func get_bullet_gravity():
	return get_stat("ProjectileGravity");

@export var firingOffsetNode : Node3D;
var firingOffset : Vector3;

@export_subgroup("Firing FX")
@export var firingSoundString := "Weapon.Shoot.Heavy"
@export var firingSoundPitchAdjust := 3.0;
@export var firingSoundVolumeAdjust := 0.75;
@export var firingName := "Fire";
@export var firingDescription := "Fires a damaging projectile.";
var leakTimer := 3.0;

############ INIT STUFF

func phys_process_timers(delta):
	super(delta);
	leakTimer -= delta;

func assign_references():
	super();
	if !is_instance_valid(rangeRay):
		var nodeCheck = get_node_or_null("Meshes/RangeRay")
		if nodeCheck != null:
			rangeRay = nodeCheck;
		else:
			var newRay = RayCast3D.new()
			newRay.add_exception(hurtboxCollisionHolder);
			newRay.exclude_parent = true;
			newRay.collision_mask = 64 + 1; ##Hurtboxes and robots.
			#newRay.add_exception(hurtboxCollisionHolder);
			if is_instance_valid(rangeRay):
				meshesHolder.add_child(newRay);

func stat_registry():
	super();
	register_stat("MagazineSize", magazineMaxBase, statIconMagazine, null, null, StatTracker.roundingModes.Floori);
	register_stat("MagazineRefreshRate", magazineRefreshRate, statIconCooldown);
	register_stat("ProjectileSpeed", launchSpeed, statIconCooldown);
	register_stat("ProjectileLifetime", bulletLifetime, statIconCooldown);
	register_stat("ProjectileGravity", bulletGravity, statIconWeight);
	register_stat("ProjectileFireRate", fireRate, statIconCooldown);
	register_stat("Inaccuracy", bulletLifetime, statIconWeight);

func get_magazine_max() -> int:
	return get_stat("MagazineSize");
func get_projectile_speed():
	return get_stat("ProjectileSpeed");
func get_projectile_lifetime():
	return get_stat("ProjectileLifetime");
func get_inaccuracy():
	return get_stat("Inaccuracy");

func ability_registry():
	super();
	#register_active_ability(firingName, firingDescription, func(): fireBullet(); pass, [])
	pass;

func can_use_active(slot : AbilityManager):
	if can_fire():
		return super(slot);
	return false;

func get_firing_offset():
	if is_instance_valid(firingOffsetNode):
		return firingOffsetNode.global_position;
	return firingOffset + global_position;

################### FIRING

func refill_magazine(max := get_magazine_max()):
	var newMagazine : Array[Bullet] = []
	var count = 0;
	for bullet in magazine:
		if count < max:
			if is_instance_valid(bullet):
				count += 1;
				newMagazine.append(bullet);
	
	while newMagazine.size() < max:
		var bullet : Bullet;
		bullet = bulletRef.instantiate();
		if bullet is Bullet:
			var wrld = GameState.get_game_board();
			if wrld == null: return;
			wrld.add_child(bullet);
			newMagazine.append(bullet);
	
	magazine = newMagazine;
	pass;

var availableBullets = 0;
func add_one_bullet(max := get_magazine_max()):
	#print("Adding a bullet")
	availableBullets = min(availableBullets + 1, max);
	#print(availableBullets)

func get_available_bullets():
	#print("Bulelts available: ", availableBullets)
	return availableBullets;

func fireBullet():
	#print("pew");
	
	var bullet : Bullet;
	
#	##Create new bullets when there are less than there should be
	
	bullet = nextBullet();
	
	if is_instance_valid(bullet):
		firingAngle = Vector3(0,0,1);
		firingAngle += inaccuracy * Vector3(randf_range(-1,1),randf_range(0,0),randf_range(-1,1));
		firingAngle = firingAngle.rotated(Vector3(1,0,0), global_rotation.x)
		firingAngle = firingAngle.rotated(Vector3(0,1,0), global_rotation.y)
		firingAngle = firingAngle.rotated(Vector3(0,0,1), global_rotation.z)
		#Hooks.OnFireProjectile(self, bullet); ##TODO: Hooks implementation
		firingAngle = firingAngle.normalized();
		var bot = get_host_robot();
		var pos = bot.get_global_body_position() + firingOffset;
		pos = get_firing_offset();
		#prints("Firing offset",get_firing_offset())
		bullet.fire_from_robot(bot, self, pos, get_damage_data(), firingAngle, launchSpeed, bulletLifetime, get_bullet_gravity());
		SND.play_sound_at(firingSoundString, pos, GameState.get_game_board(), firingSoundVolumeAdjust, randf_range(firingSoundPitchAdjust * 1.15, firingSoundPitchAdjust * 0.85))
		availableBullets -= 1;
	else:
		for bullt in magazine:
			print(bullt)
		print("Invalid bullet")
		#print(magazine)
	leak_timer_start();
	pass

##Checks the magazine for the amount of available bullets in there.
func recountMagazine() -> int:
	refill_magazine();
	
	var max = get_magazine_max();
	var count = max;
	for bullet in magazine:
		if is_instance_valid(bullet):
			if ! bullet.available(true):
				count -= 1;
	var finalCount = max(count, 0);
	magazineCount = finalCount;
	#print("recounting... final count is ", magazineCount)
	return min(get_available_bullets(), finalCount);

##Checks the magazine to see if you're able to fire.
func can_fire() -> bool: 
	return recountMagazine() > 0;

##Checks the magazine for the next non-fired bullet.
func nextBullet():
	for bullet in magazine:
		var bulletIDX = magazine.find(bullet);
		if is_instance_valid(bullet):
			if bullet.available():
				#print(bullet)
				return bullet;
	return null;

##Deletes the entire magazine.
func leakPrevention():
	##Deletes the entire magazine 
	for bullet in magazine:
		if is_instance_valid(bullet):
			bullet.leak();
	magazine.clear();

func leak_timer_start():
	leakTimer = 3.0;

func leak_timer_timeout():
	leakPrevention();
	leak_timer_start();

func _exit_tree():
	leakPrevention();
	pass;

func calc_range():
	await ready;
	var delta = get_physics_process_delta_time();
	var length = launchSpeed * delta * bulletLifetime * 60;
	rangeRay.target_position.x = length;
	rangeRay.position = firingOffset;

func get_closest_thing_in_line_of_fire():
	if rangeRay.is_colliding():
		return rangeRay.get_collider();
	return null;

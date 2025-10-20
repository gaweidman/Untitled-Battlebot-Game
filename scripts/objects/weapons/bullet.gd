extends FreezableEntity
class_name Bullet

var dir := Vector3(0,0,0);
var speed := 30.0;
@export var knockbackMult := 1000.0;
@export var sizeMult := Vector3(1.0,1.0,1.0);
var damage := 1.0;
var fired := false;
var lifetime := 1.0;
@export var lifeTimer : Timer;
var lifeDeltaTimer := 1.0;
@export var raycast : RayCast3D;
@export var collision : CollisionShape3D;
var initPosition = position;
var positionAppend := Vector3.ZERO;
## @deprecated
var launcher : PartActive; 
var launcherPiece : Piece;
var attacker : Node3D;
var originalAttacker : Node3D;
@export var tracerFXString := "BulletTracer_small";
var damageData : DamageData;
@export var hitbox : Area3D;
@export var gravity := -0.0987;
var verticalVelocity := 0.0;
var framesAlive := 0;
#var hitSomething := false;

var leaking := false;

func _ready():
	die();

## Whether this bullet is available to be scooped up and fired or not.
func available(printWhy := false):
	if leaking: 
		Utils.print_if_true("Bullet leaking", printWhy)
		return false;
	if fired: 
		Utils.print_if_true("Already fired", printWhy)
		return false;
	if lifeDeltaTimer < 0: 
		Utils.print_if_true(("Alive too long, "+str(lifeDeltaTimer)), printWhy)
		return false;
	if is_queued_for_deletion(): 
		Utils.print_if_true("Queued for deletion", printWhy)
		return false;
	#if hitSomething: return false;
	return true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta);
	if not is_frozen():
		if fired && visible:
			positionAppend += (dir * speed * delta);
			positionAppend += Vector3(0,1,0) * verticalVelocity;
			verticalVelocity += gravity * delta;
			#print(verticalVelocity)
			var oldPos = global_position;
			position = initPosition + positionAppend;
			var newPos = global_position;
			var positionDif = oldPos - newPos;
			var difLen = positionDif.length();
			raycast.position.z = difLen;
			raycast.target_position.z = -difLen;
			if raycast.is_colliding():
				var col = raycast.get_collider();
				#print("Bullet Raycast hit something this time")
				shot_something(col);
	if not visible:
		if leaking:
			die();
	pass

func phys_process_timers(delta):
	super(delta);
	if not is_frozen():
		if fired and visible:
			if lifeDeltaTimer < 0:
				_on_life_timer_timeout();
			lifeDeltaTimer -= delta;
		else:
			lifeDeltaTimer = 0;


## @deprecated : This is here for compatibility reasons until we can completely flush out all references to Combatants.
func fire(_attacker : Combatant, _launcher : Node ,_initPosition : Vector3, _direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 1.0, _damage := 1.0):
	set_attacker(_attacker);
	originalAttacker = _attacker;
	if ! is_instance_valid(attacker): 
		die()
		return
	launcher = _launcher;
	speed = _fireSpeed;
	dir = _direction;
	lifetime = _lifetime;
	lifeTimer.wait_time = lifetime;
	lifeTimer.start();
	damage = _damage;
	positionAppend = Vector3.ZERO;
	initPosition = _initPosition;
	set_deferred("scale", sizeMult);
	position = initPosition;
	collision.set_deferred("disabled", false);
	raycast.set("enabled", true);
	rotateTowardVector3(dir);
	
	show();
	ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), Vector3.ZERO, 0.5, self);
	ParticleFX.play(tracerFXString, GameState.get_game_board(), Vector3.ZERO, sizeMult, self,);
	fired = true;
	print("I have been fired at ", global_position, ", attacker is at ", attacker.global_position)

func fire_from_robot(_attacker : Robot, _launcher : Piece ,_initPosition : Vector3, _damageData : DamageData, _direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 1.0, _gravity := -0.0987):
	launcherPiece = _launcher;
	set_attacker(_attacker);
	if ! is_instance_valid(attacker): 
		die();
		return;
	speed = _fireSpeed;
	dir = _direction;
	verticalVelocity = 0.0;
	lifetime = _lifetime;
	lifeDeltaTimer = lifetime;
	#lifeTimer.wait_time = lifetime;
	#lifeTimer.start();
	gravity = _gravity;
	damageData = _damageData;
	positionAppend = Vector3.ZERO;
	initPosition = _initPosition;
	set_deferred("scale", sizeMult);
	position = initPosition;
	collision.set_deferred("disabled", false);
	raycast.set("enabled", true);
	rotateTowardVector3(dir);
	
	show();
	unfreeze();
	ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), Vector3.ZERO, 0.5, self);
	ParticleFX.play(tracerFXString, GameState.get_game_board(), Vector3.ZERO, sizeMult, self,);
	fired = true;
	print("I have been fired at ", global_position, ", attacker is at ", attacker.global_position)

func rotateTowardVector3(dir : Vector3):
	look_at(global_transform.origin + dir, Vector3.UP)
	rotation.x = dir.y;

func change_direction(newAngle : Vector3):
	dir = newAngle;
	rotateTowardVector3(dir);

func flip_direction():
	dir *= -1;
	rotateTowardVector3(dir);

func die():
	if visible:
		ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), position, 0.5);
	#position = Vector3.ZERO;
	fired = false;
	collision.set("disabled", true);
	raycast.set("enabled", false);
	hide();
	set_attacker(originalAttacker);
	if leaking:
		queue_free();
	pass

func _on_life_timer_timeout():
	die();
	pass # Replace with function body.

func _on_body_entered(body):
	shot_something(body);
	pass # Replace with function body.

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not leaking and body is RobotBody and body.get_parent() != get_attacker():
		print("tis a robot. from ", name)
		var other_shape_owner = body.shape_find_owner(body_shape_index)
		var other_shape_node = body.shape_owner_get_owner(other_shape_owner)
		if other_shape_node is not PieceCollisionBox: return;
		
		var local_shape_owner = hitbox.shape_find_owner(local_shape_index)
		var local_shape_node = hitbox.shape_owner_get_owner(local_shape_owner)
		#if local_shape_node is not PieceCollisionBox: return;
		
		var otherPiece : Piece = other_shape_node.get_piece();
		print("Other Piece in hitbox collision: ", otherPiece)
		if ! is_instance_valid(otherPiece): return;
		print("Bullet damage commencing:")
		shot_something(body);
	pass # Replace with function body.

func shot_something(inbody):
	if leaking: return;
	if ! is_instance_valid(inbody): return;
	if ! visible: return;
	if get_current_position() == initPosition: return;
	var validTarget = false;
	var parent = inbody.get_parent();
	if parent == attacker:
		return;
	if parent is Combatant:
		#print(inbody.get_parent())
		parent.take_damage(damage);
		parent.call_deferred("take_knockback",(dir + Vector3(0,0.01,0)) * knockbackMult);
		print("should be taking knockback....")
		validTarget = true;
	if inbody is RobotBody:
		parent = inbody.get_robot()
		if !is_instance_valid(damageData):
			print_rich("[color=purple]Bullet needs a new DamageData")
			damageData = DamageData.new();
			damageData.create(damage, knockbackMult, dir, [DamageData.damageTypes.PIERCING])
		#print(inbody.get_parent())
		print_rich("[color=purple]Bullet hit robot. Yippie!")
		parent.take_damage_from_damageData(damageData);
		validTarget = true;
		#parent.call_deferred("take_knockback",(dir + Vector3(0,0.01,0)) * knockbackMult);
		#print("should be taking knockback....")
	#print("Shot ded by ",inbody, " named: ", inbody.name)
	
	#if not ( inbody.is_in_group("Player Part") ):
		#die()
		#;
		
	#Hooks.OnCollision(self, inbody);
	prints("Bullet hit a thing! If this doesn't show, then something borked...")
	prints("BULLET INBODY: ", inbody)
	prints(self, inbody)
	prints(fired, lifeTimer, lifeDeltaTimer)
	SND.play_collision_sound(self, inbody, get_current_position(), 0.85, 1.5);
	ParticleFX.play("Sparks", GameState.get_game_board(), get_current_position(), 0.5);
	
	#hitSomething = true;
	#print(validTarget)
	die();

func leak():
	leaking = true;
func get_current_position():
	return initPosition + positionAppend;

func get_attacker():
	return attacker;
func get_launcher():
	return launcherPiece;

func set_attacker(atkr):
	attacker = atkr;
	if attacker is Combatant:
		raycast.clear_exceptions();
		raycast.add_exception(get_attacker().body);
	if attacker is Robot:
		raycast.clear_exceptions();
		raycast.add_exception(get_attacker().body);
		raycast.add_exception(get_launcher().hurtboxCollisionHolder);

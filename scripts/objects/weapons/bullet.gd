extends Area3D
class_name Bullet

var dir := Vector3(0,0,0);
var speed := 30.0;
@export var knockbackMult := 1000.0;
@export var sizeMult := Vector3(1.0,1.0,1.0);
var damage := 1.0;
var fired := false;
var lifetime := 1.0;
@export var lifeTimer : Timer;
@export var raycast : RayCast3D;
@export var collision : CollisionShape3D;
var initPosition = position;
var positionAppend := Vector3.ZERO;
var launcher : PartActive;
var attacker : Node3D;
@export var tracerFXString := "BulletTracer_small";

var leaking := false;

func _ready():
	die();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if fired && visible:
		positionAppend += (dir * speed * delta);
		var oldPos = global_position;
		position = initPosition + positionAppend;
		var newPos = global_position;
		var positionDif = oldPos - newPos;
		var difLen = positionDif.length();
		raycast.position.z = difLen;
		raycast.target_position.z = -difLen;
		if raycast.is_colliding():
			var col = raycast.get_collider();
			print("Bullet Raycast hit something this time")
			shot_something(col);
	if not visible:
		if leaking:
			die();
	pass

func fire(_attacker : Combatant, _launcher : Node ,_initPosition : Vector3, _direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 1.0, _damage := 1.0):
	set_attacker(_attacker);
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
	rotateTowardVector3(dir);
	
	show();
	ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), Vector3.ZERO, 0.5, self);
	ParticleFX.play(tracerFXString, GameState.get_game_board(), Vector3.ZERO, sizeMult, self,);
	fired = true;
	print("I have been fired at ", global_position, ", attacker is at ", attacker.global_position)

func rotateTowardVector3(dir : Vector3):
	look_at(global_transform.origin + dir, Vector3.UP)

func change_direction(newAngle : Vector3):
	dir = newAngle;
	rotateTowardVector3(dir);

func die():
	if visible:
		ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), position, 0.5);
	position = Vector3.ZERO;
	fired = false;
	collision.set_deferred("disabled", true);
	hide();
	if leaking:
		queue_free();
	pass

func _on_life_timer_timeout():
	die();
	pass # Replace with function body.

func _on_body_entered(body):
	shot_something(body);
	pass # Replace with function body.

func shot_something(body):
	if leaking: return;
	if ! is_instance_valid(body): return;
	if body.get_parent() == attacker:
		#print("                     entered my attacker")
		return;
	if body.get_parent() is Combatant:
		#print(body.get_parent())
		body.get_parent().take_damage(damage);
		body.get_parent().call_deferred("take_knockback",(dir + Vector3(0,0.01,0)) * knockbackMult);
		print("should be taking knockback....")
	#print("Shot ded by ",body, " named: ", body.name)
	
	#if not ( body.is_in_group("Player Part") ):
		#die()
		#;
		
	Hooks.OnCollision(self, body);
	SND.play_collision_sound(self, body, initPosition + positionAppend, 0.85, 1.5);
	ParticleFX.play("Sparks", GameState.get_game_board(), initPosition + positionAppend, 0.5);
	
	die();

func leak():
	leaking = true;

func get_attacker():
	return attacker;
	
func set_attacker(atkr):
	attacker = atkr;
	if attacker is Combatant:
		raycast.clear_exceptions();
		raycast.add_exception(get_attacker().body);
	if attacker is Robot:
		raycast.clear_exceptions();
		raycast.add_exception(get_attacker().body);
		raycast.add_exception(get_attacker().hurtboxCollisionHolder)

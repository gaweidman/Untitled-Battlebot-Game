extends Area3D
class_name Bullet


var dir := Vector3(0,0,0);
@export var speed := 30.0;
var fired := false;
var lifetime := 1.0;
@export var lifeTimer : Timer;
@export var collision : CollisionShape3D;
var initPosition = position;
var positionAppend := Vector3.ZERO;
var launcher : PartActive;
var attacker : Node3D;

var leaking := false;

func _ready():
	die();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fired && visible:
		positionAppend += (dir * speed * delta);
		position = initPosition + positionAppend;
	pass

func fire(_launcher : Node ,_initPosition : Vector3, _direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 1.0):
	launcher = _launcher;
	speed = _fireSpeed;
	dir = _direction;
	lifetime = _lifetime;
	lifeTimer.wait_time = lifetime;
	lifeTimer.start();
	positionAppend = Vector3.ZERO;
	initPosition = _initPosition;
	position = initPosition;
	collision.set_deferred("disabled", false);
	rotateTowardVector3(dir);
	print("PARENT", _launcher, _launcher.get_parent());
	
	show();
	fired = true;

func rotateTowardVector3(dir : Vector3):
	look_at(global_transform.origin + dir, Vector3.UP)

func die():
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
	if body.get_parent() is Combatant:
		body.get_parent().take_damage(1);
	
	if not ( body.is_in_group("Player Part") ):
		die();
	pass # Replace with function body.

func leak():
	leaking = true;

func get_attacker():
	return attacker;
	
func set_attacker(atkr):
	attacker = atkr;

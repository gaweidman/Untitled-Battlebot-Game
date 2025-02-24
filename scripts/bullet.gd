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
var launcher : ProjectileLauncher;

var leaking := false;

func _ready():
	die();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fired && visible:
		positionAppend += (dir * speed * delta);
		position = initPosition + positionAppend;
	pass

func fire(_launcher : ProjectileLauncher ,_initPosition : Vector3, _direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 1.0):
	launcher = _launcher;
	speed = _fireSpeed;
	dir = _direction;
	lifetime = _lifetime;
	lifeTimer.wait_time = lifetime;
	lifeTimer.start();
	positionAppend = Vector3.ZERO;
	initPosition = _initPosition;
	position = initPosition;
	print(position)
	collision.disabled = false;
	show();
	fired = true;

func die():
	position = Vector3.ZERO;
	fired = false;
	collision.disabled = true;
	hide();
	if leaking:
		queue_free();
	pass

func _on_life_timer_timeout():
	die();
	pass # Replace with function body.

func _on_body_entered(body):
	die();
	pass # Replace with function body.

func leak():
	leaking = true;

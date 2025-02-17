extends Area3D
class_name Bullet


var dir := Vector3(0,0,0);
@export var speed := 30.0;
var fired := false;
var lifetime := 2.0;
@export var lifeTimer : Timer;
@export var collision : CollisionShape3D;

func _ready():
	die();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fired && visible:
		position += dir * speed * delta;
	pass

func fire(_direction := Vector3(1,0,0), _fireSpeed := 30.0, _lifetime := 2.0):
	speed = _fireSpeed;
	dir = _direction;
	lifetime = 2.0;
	lifeTimer.wait_time = lifetime;
	show();
	fired = true;

func _on_body_entered(body):
	
	pass # Replace with function body.

func die():
	position = Vector3.ZERO;
	fired = false;
	hide();
	pass

func _on_life_timer_timeout():
	die();
	pass # Replace with function body.

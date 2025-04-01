extends PartActive

class_name PartActiveProjectile

#@onready var bulletRef : ;
@export var bulletRef : PackedScene;
var magazine = [];
var magazineCount := 0;
@export var magazineMax := 3;
@export var fireSpeed := 30.0;
@export var bulletLifetime := 1.0;
@export var firingAngle := Vector3.BACK;

var leakTimer : Timer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	#inputHandler = $"../InputHandler"
	leakTimer = $LeakTimer;
	pass # Replace with function body.

func _activate():
	super();
	if can_fire():
		fireBullet();
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta);
	pass

func fireBullet():
	print("pew");
	var bullet : Bullet;
	
#	##Create new bullets when there are less than there should be
	if magazine.size() < magazineMax:
		bullet = bulletRef.instantiate();
		get_node("/root/GameBoard").add_child(bullet);
		magazine.append(bullet);
	
	bullet = nextBullet();
	
	if is_instance_valid(bullet):
		##This offset can be changed later to be controllable
		var offset = Vector3(0,1,0);
		firingAngle = InputHandler.mouseProjectionRotation(positionNode);
		
		bullet.fire(self, positionNode.position + offset, firingAngle, fireSpeed, bulletLifetime);
		_set_fire_rate_timer();
	
	leakTimer.start();
	GameState.get_hud().update();
	pass

func recountMagazine() -> int:
	##Checks the magazine for the amount of available bullets in there
	var count = magazineMax;
	for bullet in magazine:
		if is_instance_valid(bullet):
			if bullet.fired:
				count -= 1;
	var finalCount = max(count, 0);
	magazineCount = finalCount;
	return finalCount;

func nextBullet():
	##Checks the magazine for the next non-fired bullet
	for bullet in magazine:
		if is_instance_valid(bullet) && (not bullet.fired):
			print("not fired?");
			return bullet;
	return null;

func leakPrevention():
	print("There's a leek in the boat...")
	##Deletes the entire magazine 
	for bullet in magazine:
		if is_instance_valid(bullet):
			bullet.leak();
	magazine.clear();

func _on_leak_timer_timeout():
	leakPrevention();
	pass;

func _exit_tree():
	leakPrevention();
	pass;

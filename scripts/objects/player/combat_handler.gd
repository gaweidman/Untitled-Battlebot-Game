extends Node3D

class_name CombatHandler

#@onready var bulletRef : ;
@export var bulletRef : PackedScene;
var magazine = [];
var magazineCount := 0;
@export var magazineMax := 3;
@export var fireSpeed := 30.0;
@export var bulletLifetime := 1.0;
@export var firingAngle := Vector3.BACK;

@export var fireRate := 0.15;
@export var fireRateTimer := 0.0;
@export var positionNode : Node3D; ##This needs to be the thing with the position on it - in thbis case, the Body node
@export var startingHealth: int;

var maxHealth = 3;
var health = maxHealth;

var inputHandler;
var leakTimer : Timer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = $"../InputHandler"
	leakTimer = $LeakTimer;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if fireRateTimer <= 0:
		pass
	else:
		fireRateTimer -= delta;
	pass

func can_fire() -> bool: 
	return fireRateTimer <= 0;
		##Temp condition, can be changed later

func fireBullet():
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
		firingAngle = inputHandler.mouseProjectionRotation(positionNode);
		
		bullet.fire(self, positionNode.position + offset, firingAngle, fireSpeed, bulletLifetime);
		fireRateTimer = fireRate;
	
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
			return bullet;
	return null;

func take_damage(damage):
	health -= damage;
	get_node("../GUI/Health").text = "Health: " + health + "/" + maxHealth;
	if health <= 0:
		die();
		
	GameState.get_hud().update();
		
func die():
	queue_free();
	
func _on_collision(colliderdw):
	pass

func leakPrevention():
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

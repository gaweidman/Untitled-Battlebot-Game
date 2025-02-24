extends Node

#@onready var bulletRef : ;
@export var bulletRef : PackedScene;
var magazine = [];
@export var magazineMax := 3;
@export var fireSpeed := 30.0;
@export var bulletLifetime := 1.0;
@export var firingAngle := Vector3.BACK;

@export var fireRate := 0.15;
@export var launcher : Node3D;
@export var startingHealth: int;

var health;
var maxHealth;

var inputHandler;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = $InputHandler
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
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
		var offset = Vector3(0,1,0)
		
		bullet.fire($ProjectileLauncher, launcher.position + offset, firingAngle, fireSpeed, bulletLifetime);
		inputHandler.fireRateTimer = fireRate;
	pass

func recountMagazine() -> int:
	##Checks the magazine for the amount of available bullets in there
	var count = magazineMax;
	for bullet in magazine:
		if is_instance_valid(bullet):
			if bullet.fired:
				count -= 1;
	return max(count, 0);

func nextBullet():
	##Checks the magazine for the next non-fired bullet
	for bullet in magazine:
		if is_instance_valid(bullet) && (not bullet.fired):
			print("not fired?");
			return bullet;
	return null;

func take_damage(damage):
	print("TAKING DAMAGE");
	health -= damage;
	get_node("../GUI/Health").text = "Health: " + health + "/" + maxHealth;
	if health <= 0:
		die();
		
func die():
	print("WE ARE DYING")
	queue_free();
	
func _on_collision(colliderdw):
	pass

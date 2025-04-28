extends PartActive

class_name PartActiveProjectile

#@onready var bulletRef : ;
@export var bulletRef : PackedScene;
var magazine = [];
var magazineCount := 0;
##The base max amount of bullets in the magazine.
@export var magazineMaxBase := 3;
##Calculated magazine size.
var magazineMax := magazineMaxBase;
##Modifier of the max amount of bullets in the mag.
var magazineMaxModifier := 1.0;
@export var fireSpeed := 30.0;
@export var bulletLifetime := 1.0;
@export var firingAngle := Vector3.BACK;
@export var firingOffset := Vector3(0,0.50,0);
@export_category("Firing Sound")
@export var firingSoundString := "Weapon.Shoot.Heavy"
@export var firingSoundPitchAdjust := 3.0;
@export var firingSoundVolumeAdjust := 0.75;

var leakTimer : Timer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	#inputHandler = $"../InputHandler"
	leakTimer = $LeakTimer;
	pass # Replace with function body.

func _activate():
	if super():
		if can_fire():
			fireBullet();
			return true;
		else:
			return false;
	else:
		return false;
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta);
	magazineMax = magazineMaxBase * magazineMaxModifier;
	pass

func get_magazine_size(base:=false):
	if base: return magazineMaxBase * magazineMaxModifier;
	return magazineMax;

func fireBullet():
	#print("pew");
	var bullet : Bullet;
	
	#print( "PARENT!!!!!       ", self.get_parent().get_parent() );
	
#	##Create new bullets when there are less than there should be
	if magazine.size() < magazineMax:
		bullet = bulletRef.instantiate();
		get_node("/root/GameBoard").add_child(bullet);
		magazine.append(bullet);
		
	Hooks.OnFireProjectile(self, bullet);
	
	bullet = nextBullet();
	
	if is_instance_valid(bullet):
		if thisBot is Player:
			firingAngle = InputHandler.mouseProjectionRotation(positionNode);
		else:
			firingAngle = InputHandler.playerPosRotation(positionNode);
		
		bullet.fire(thisBot, self, positionNode.global_position + firingOffset + modelOffset, firingAngle, fireSpeed, bulletLifetime, get_damage());
		
		SND.play_sound_at(firingSoundString, positionNode.global_position + firingOffset + modelOffset, GameState.get_game_board(), firingSoundVolumeAdjust, randf_range(firingSoundPitchAdjust * 1.15, firingSoundPitchAdjust * 0.85))
	
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

func can_fire() -> bool: 
	if fireRateTimer <= 0:
		if recountMagazine() > 0:
			if GameState.get_in_state_of_play():
				if get_equipped():
					return true;
	return false;

func nextBullet():
	##Checks the magazine for the next non-fired bullet
	for bullet in magazine:
		if is_instance_valid(bullet) && (not bullet.fired):
			#print("not fired?");
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

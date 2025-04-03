extends Node

# These are the types of players that can be in the game. COLLISION2
# through COLLISION8 exist solely for the world, at least at the
# moment. There are 8 COLLISION instances for the world, so multiple
# collision sounds can happen at the same without any of the other sounds
# being cut off.
enum Audio {
	MOVEMENT, AMBIENT, WEAPON, COLLISION, 
	COLLISION2, COLLISION3, COLLISION4, COLLISION5,
	COLLISION6, COLLISION7, COLLISION8,
}

enum AudioSrc {
	COMBATANT,
	WEPRANGED,
	WORLD,
	WEPMELEE
}

# All sounds in the game have a type assigned to them. Their type is determined
# by what the sounds are of. There are multiple keywords in a type, separated 
# with periods. From left to right, the description gets more and more specific.

# As this is a dictionary, the types are only the keys. The values are lists
# of different soundfiles of the type they belong to. When playing a sound,
# the game must use the pick_sound function to pick one sound out of the
# possibly multiple options.

var SOUNDS = {
	"Collision.Combatant.Metal": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.Combatant.Plastic": [
		load("res://sounds/collision/Plastic_Light_01.wav"),
		load("res://sounds/collision/Plastic_Light_02.wav"),
		load("res://sounds/collision/Plastic_Light_03.wav"),
	],
	
	"Collision.Combatant.Concrete": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.Combatant.Sawblade": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.Combatant.Combatant": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.Projectile.Metal": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.Projectile.Plastic": [
		load("res://sounds/collision/Plastic_Light_01.wav"),
		load("res://sounds/collision/Plastic_Light_02.wav"),
		load("res://sounds/collision/Plastic_Light_03.wav"),
	],
	
	"Collision.Projectile.Concrete": [
		load("res://sounds/collision/Concrete_Bullet_01.wav"),
		load("res://sounds/collision/Concrete_Bullet_02.wav"),
		load("res://sounds/collision/Concrete_Bullet_03.wav")
	],
	
	"Collision.Projectile.Combatant": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.MeleeWeapon.Metal": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.MeleeWeapon.Plastic": [
		load("res://sounds/collision/Plastic_Light_01.wav"),
		load("res://sounds/collision/Plastic_Light_02.wav"),
		load("res://sounds/collision/Plastic_Light_03.wav"),
	],
	
	"Collision.MeleeWeapon.Sawblade": [
		load("res://sounds/collision/Metal_Ting_01.wav"), 
		load("res://sounds/collision/Metal_Ting_02.wav")
	], 
	
	"Collision.MeleeWeapon.Concrete": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.World.Metal": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Collision.World.Plastic": [
		load("res://sounds/collision/Plastic_Light_01.wav"),
		load("res://sounds/collision/Plastic_Light_02.wav"),
		load("res://sounds/collision/Plastic_Light_03.wav"),
	],
	
	"Collision.World.Concrete": [
		load("res://sounds/collision/Metal_Light_01.wav"),
		load("res://sounds/collision/Metal_Light_02.wav"),
		load("res://sounds/collision/Metal_Light_03.wav")
	],
	
	"Weapon.Shoot": [load("res://sounds/CannonFire01.wav")],
	"Weapon.Sawblade.Drone": [load("res://sounds/Sawblade.wav")],
	
	"Movement.Drone": [load("res://sounds/Movement_Drone.ogg")],
	"Movement.Dash": [load("res://sounds/Toaster.wav")]
}

# When two things collide, what noise do we make? If the sawblade hits the
# world, do we hear the metallic sawblade, or the concrete of the world? This
# is part of how we figure it out. The higher value a key has, the more
# priority it has in being played.
var COLLIDER_PRIORITIES = {
	"Combatant": 4,
	"Projectile": 3,
	"World": 2,
	"MeleeWeapon": 1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Picks one of multiple .wav file options for a given sound.
func pick_sound(soundType):
	var soundOptions = SOUNDS[soundType];
	
	var rand = RandomNumberGenerator.new();
	rand.randomize();
	
	return soundOptions[rand.randi_range(0, len(soundOptions) - 1)];

# Takes two objects that collided with each other, and returns the proper sound
# that should be played for the collision.
func get_proper_sound(collider1: Node3D, collider2: Node3D):
	var collider1Audiosrc;
	var collider2Audiosrc;
	
	if collider1.is_in_group("Combatant"):
		collider1Audiosrc = "Combatant"
	elif collider1.is_in_group("MeleeWeapon"):
		collider1Audiosrc = "MeleeWeapon"
	elif collider1.is_in_group("World"):
		collider1Audiosrc = "World"
	elif collider1.is_in_group("Projectile"):
		collider1Audiosrc = "Projectile";
		
	if collider2.is_in_group("Combatant"):
		collider2Audiosrc = "Combatant"
	elif collider2.is_in_group("MeleeWeapon"):
		collider2Audiosrc = "MeleeWeapon"
	elif collider2.is_in_group("World"):
		collider2Audiosrc = "World"
	elif collider2.is_in_group("Projectile"):
		collider2Audiosrc = "Projectile";
		
	var collider1Priority = COLLIDER_PRIORITIES[collider1Audiosrc];
	var collider2Priority = COLLIDER_PRIORITIES[collider2Audiosrc];
	
	# the node that will be making the sound.
	var soundMaker;
	var soundMakerAudiosrc
	if collider1Priority > collider2Priority:
		soundMaker = collider1;
		soundMakerAudiosrc = collider1Audiosrc;
	else:
		soundMaker = collider2;
		soundMakerAudiosrc = collider2Audiosrc;
		
	var material;
	if soundMaker.is_in_group("Metal"):
		material = "Metal"
	elif soundMaker.is_in_group("Concrete"):
		material = "Concrete"
	elif soundMaker.is_in_group("Plastic"):
		material = "Plastic"
		
	return "Collision." + soundMakerAudiosrc + "." + material

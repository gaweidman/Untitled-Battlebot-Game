extends Node

# These are the types of players that can be in the game. AUDIO_COLLISION2
# through AUDIO_COLLISION10 exist solely for the world, at least at the
# moment. There are 8 AUDIO_COLLISION instances for the world, so multiple
# collision sounds can happen at the same without any of the other sounds
# being cut off.
enum {
	AUDIO_MOVEMENT, AUDIO_AMBIENT, AUDIO_WEAPON, AUDIO_COLLISION, 
	AUDIO_COLLISION2, AUDIO_COLLISION3, AUDIO_COLLISION4, AUDIO_COLLISION5,
	AUDIO_COLLISION6, AUDIO_COLLISION7, AUDIO_COLLISION8,
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
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Combatant.Plastic": [
		"res://sounds/collision/Plastic_Light_01.wav",
		"res://sounds/collision/Plastic_Light_02.wav",
		"res://sounds/collision/Plastic_Light_03.wav",
	],
	
	"Collision.Combatant.Concrete": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Combatant.Sawblade": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Combatant.Combatant": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Projectile.Metal": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Projectile.Plastic": [
		"res://sounds/collision/Plastic_Light_01.wav",
		"res://sounds/collision/Plastic_Light_02.wav",
		"res://sounds/collision/Plastic_Light_03.wav",
	],
	
	"Collision.Projectile.Concrete": [
		"res://sounds/collision/Concrete_Bullet_01.wav",
		"res://sounds/collision/Concrete_Bullet_02.wav",
		"res://sounds/collision/Concrete_Bullet_03.wav"
	],
	
	"Collision.Projectile.Combatant": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Sawblade.Metal": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Collision.Sawblade.Plastic": [
		"res://sounds/collision/Plastic_Light_01.wav",
		"res://sounds/collision/Plastic_Light_02.wav",
		"res://sounds/collision/Plastic_Light_03.wav",
	],
	
	"Collision.Sawblade.Sawblade": [
		"res://sounds/collision/Metal_Ting_01.wav", 
		"res://sounds/collision/Metal_Ting_02.wav"
	], 
	
	"Collision.Sawblade.Concrete": [
		"res://sounds/collision/Metal_Light_01.wav",
		"res://sounds/collision/Metal_Light_02.wav",
		"res://sounds/collision/Metal_Light_03.wav"
	],
	
	"Weapon.Shoot": ["res://sounds/CannonFire.wav"],
	"Weapon.Sawblade.Drone": ["res://sounds/Sawblade.wav"],
	
	"Movement.Drone": ["res://sounds/Movement_Drone.ogg"],
	"Movement.Dash": ["res://sounds/Toaster.wav"]
}

# A list of all the possible materials something can be made of. Used for collisions.
var MATERIALS = [
	"concrete",
	"metal",
	"plastic"
]

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
	
	return soundOptions[rand.randi_range(0, len(soundOptions))];

# Takes two objects that collided with each other, and returns the proper sound
# that should be played for the collision.
func get_proper_sound(collider1: Node3D, collider2: Node3D):
	if collider1.is_in_group("world")

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
	"Collision.Combatant.Metal": ["res://sounds/MetalThud.mp3"],
	"Collision.Combatant.Plastic": ["res://sounds/SecondPlasticHit.wav"],
	"Collision.Combatant.Sawblade": ["res://sounds/MetalClang.wav"],
	"Collision.Combatant.Combatant": ["res://sounds/FryingpanBonk.wav"],
	
	"Collision.Projectile.Metal": ["res://sounds/FryingpanBonk.wav"],
	"Collision.Projectile.Plastic": ["res://sounds/PlasticHitSound.mp3"],
	"Collision.Projectile.Sawblade": ["res://sounds/MetalClap.wav"],
	"Collision.Projectile.Combatant": ["res://sounds/MetalClap.wav"],
	
	"Collision.Sawblade.Metal": ["res://sounds/MetalClang.wav"],
	"Collision.Sawblade.Plastic": ["res://sounds/PlasticHitThree.wav"],
	"Collision.Sawblade.Sawblade": ["res://sounds/ClashSound.wav"], 
	
	"Weapon.Shoot": ["res://sounds/CannonFire.wav"],
	"Weapon.Sawblade.Drone": ["res://sounds/Sawblade.wav"],
	
	"Movement.Drone": ["res://sounds/toyTankTreads.ogg", "res://sounds/toyTankTreads_end.ogg", "res://sounds/toyTankTreads_start.ogg"],
	"Movement.Dash": ["res://sounds/Toaster.wav"]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pick_sound(soundType):
	var soundOptions = SOUNDS[soundType];
	
	var rand = RandomNumberGenerator.new();
	rand.randomize();
	
	return soundOptions[rand.randi_range(0, len(soundOptions))];

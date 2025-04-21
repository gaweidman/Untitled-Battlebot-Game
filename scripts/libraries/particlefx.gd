extends Node;

var PFX_LIST = {
	"NutsBolts": load("res://scenes/prefabs/particle-fx/BoltsHit.tscn"),
	"Smoke": load("res://scenes/prefabs/particle-fx/SmokePuffs.tscn"),
	"Sparks": load("res://scenes/prefabs/particle-fx/HitSparksTest.tscn"),
	"BulletTracer": load("res://scenes/prefabs/particle-fx/BulletTracer.tscn")
}

func _ready():
	pass
	
func _process(_delta: float):
	pass
	
func get_effect_scene(pfxName: String):
	return PFX_LIST[pfxName];

func play(pfxName: String, parent: Node3D, location: Vector3):
	var scene = get_effect_scene(pfxName);
	
	var sceneInst = scene.instantiate();
	parent.add_child(sceneInst);
	
	sceneInst.set_position(location);

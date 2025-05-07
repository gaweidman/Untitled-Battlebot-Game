extends Node;

const PFX_LIST = {
	"NutsBolts": preload("res://scenes/prefabs/particle-fx/BoltsHit.tscn"),
	"Smoke": preload("res://scenes/prefabs/particle-fx/SmokePuffs.tscn"),
	"SmokePuffSingle": preload("res://scenes/prefabs/particle-fx/SmokePuffSingle.tscn"),
	"Sparks": preload("res://scenes/prefabs/particle-fx/HitSparksTest.tscn"),
	"BulletTracer": preload("res://scenes/prefabs/particle-fx/BulletTracer.tscn"),
	"BulletTracer_small": preload("res://scenes/prefabs/particle-fx/BulletTracer.tscn")
}

func _ready():
	pass
	
func _process(_delta: float):
	pass
	
func get_effect_scene(pfxName: String):
	if pfxName in PFX_LIST:
		return PFX_LIST[pfxName];
	else:
		return null;

func play(pfxName: String, parent: Node3D, location: Vector3, _scale = 1.0, nodeToFollow = GameState.get_game_board()):
	var scale = 1.0;
	if scale is float:
		scale = _scale;
	elif scale is Vector3:
		scale = _scale;
	
	var scene = get_effect_scene(pfxName);
	
	#print("Firing particle ",pfxName," at location ",location);
	if is_instance_valid(scene):
		var sceneInst = scene.instantiate();
		
		parent.add_child(sceneInst);
		sceneInst.set("posOffset", location);
		sceneInst.set("global_position", location);
		sceneInst.set("scale", sceneInst.scale * _scale);
		sceneInst.set("nodeToFollow", nodeToFollow);

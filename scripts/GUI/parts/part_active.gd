extends Part

class_name PartActive

@export var meshNode : MeshInstance3D;
@export var model : Mesh;
@export var modelMaterial : StandardMaterial3D;
@export var modelOffset = Vector3i(0,0,0);
@export var energyCost = 0;
@export var positionNode : Node3D; ##This needs to be the thing with the position on it - in thbis case, the Body node

func _ready():
	super();
	meshNode.set_deferred("mesh", model)
	meshNode.set_deferred("surface_material_override/0", modelMaterial)

func _activate():
	##Get Inventory's energy total and subtract energyCost from it
	pass

#func _physics_process(delta):
	##if positionNode != null:
		##meshNode.position = positionNode.position;
	##meshNode.position += Vector3(0,0,1)
	#print("AAA")

func _process(delta):
	#print("why.")
	if positionNode != null:
		meshNode.position = positionNode.position;
	else:
		print('null')

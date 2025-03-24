extends Part

class_name PartActive

@export var meshNode : MeshInstance3D;
@export var model : Mesh;
@export var modelMaterial : StandardMaterial3D;
@export var modelOffset = Vector3i(0,0,0);
@export var energyCost = 0;

func _ready():
	super();
	meshNode.set_deferred("mesh", model)
	meshNode.set_deferred("surface_material_override/0", modelMaterial)

func _activate():
	##Get Inventory's energy total and subtract energyCost from it
	pass

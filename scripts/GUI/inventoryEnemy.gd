extends Inventory

class_name InventoryEnemy

func _ready():
	add_parts();

func _process(delta):
	super(delta);
	add_parts();
	pass

func add_parts():
	#add_part_from_scene(0,0, "res://scenes/prefabs/objects/parts/part_active_projectile.tscn", 0);
	pass;

extends Node3D

func _ready():
	pass
	
func get_navregion():
	return get_node("/root/GameBoard/NavRegion");

func find_path(startPos: Vector3, endPos: Vector3):
	var navMap = get_navregion().get_navigation_map();
	var path: PackedVector3Array = NavigationServer3D.map_get_path(navMap, startPos, endPos, true)
	
	print("Found a path!")
	print(path)

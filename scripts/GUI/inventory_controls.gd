extends Control

class_name InventoryControl

var defaultSize := Vector2(1152.0,647.0);

func _draw():
	var VPrect = get_viewport_rect();
	var width = VPrect.size.x;
	var height = VPrect.size.y;
	#get_parent().set_size(Vector2(100, 100));
	var parent = get_parent()
	var parentRect = parent.get_global_rect();
	var parentHeight = parentRect.size.y
	var parentWidth = parentRect.size.x
	var parentPosX = parentRect.position.x
	var parentPosY = parentRect.position.y
	
	#print(parentPos)
	%InventoryLeftEdge.set_global_position(Vector2(0, %InventoryLeftEdge.global_position.y))
	%InventoryLeftEdge.set_size(Vector2(parentPosX,395.0))
	%InventoryRightEdge.set_global_position(Vector2(parentPosX+parentWidth, %InventoryRightEdge.global_position.y))
	%InventoryRightEdge.set_size(Vector2(parentPosX,395.0))

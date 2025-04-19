extends Control

class_name Shop

func deselect():
	for stall:ShopStall in get_children():
		stall.deselect();


func close_up_shop():
	for stall:ShopStall in get_children():
		stall.deselect();
		#stall.deselect();
		if !(stall.curState == ShopStall.doorState.FROZEN):
			stall.changeState(ShopStall.doorState.CLOSED);

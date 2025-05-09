extends Node


func format_stat(num:float, decimals:int=2):
	if decimals <= 0:
		return str(round_to_dec(num, 0));
	else:
		return str(round_to_dec(num, decimals));

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


# Colors for text.
const textColors = {
	"white" : Color("ffffff"),
	"grey" : Color("e0dede"),
	"utility" : Color("aae05b"),
	"ranged" : Color("789be9"),
	"melee" : Color("ff6e49"),
	"scrap" : Color("f2ec6b"),
	"red" : Color("cf2121"),
	"unaffordable" : Color("ff0000"),
	"inaffordable" : Color("ff0000"),
}

static func set_text_color(node, color):
	if is_instance_valid(node):
		if color is Color:
			if node.get("theme_override_colors/font_color") != color:
				node.set_deferred("theme_override_colors/font_color", color);
		else:
			if color is String:
				var newCol := Color(textColors["white"]);
				if color in textColors:
					newCol = Color(textColors[color]);
				else:
					newCol = Color(color);
				if node.get("theme_override_colors/font_color") != newCol:
					node.set_deferred("theme_override_colors/font_color", newCol);

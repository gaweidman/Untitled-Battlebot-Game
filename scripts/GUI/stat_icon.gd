extends Control

class_name InspectorStatIcon

@export var textureIcon : TextureRect;
@export var lbl_amt : Label;

func load_data_from_statTracker(stat: StatTracker):
	if is_instance_valid(stat):
		textureIcon.texture = stat.statIcon;
		var statText = TextFunc.format_stat(stat.get_stat(), 2, false)
		tooltip_text = stat.statFriendlyName.capitalize() + str("\n",statText);
		lbl_amt.text = statText;
		TextFunc.set_text_color(lbl_amt, stat.textColor);

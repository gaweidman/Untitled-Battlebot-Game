extends Control

class_name InspectorStatIcon

func load_data(stat: StatTracker):
	$EnergyIcon.texture = stat.statIcon;
	var statText = TextFunc.format_stat(stat.get_stat(), 2)
	tooltip_text = stat.statFriendlyName.capitalize() + str(statText);
	$EnergyIcon/Amt.text = statText;
	TextFunc.set_text_color($Amt, stat.textColor);

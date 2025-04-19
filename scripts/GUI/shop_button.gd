extends TextureButton

func _on_button_up():
	$TextHolder.position.y = 0;
	pass # Replace with function body.

func _on_button_down():
	$TextHolder.position.y = 3;
	pass # Replace with function body.

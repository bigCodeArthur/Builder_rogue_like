extends Button

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		text = "creator"
	else:
		text = "animator"

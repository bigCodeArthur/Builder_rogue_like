extends Camera3D
var up_pos = position
var down_pos = up_pos + Vector3.DOWN * 20


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"): 
		position = down_pos
	else: 
		position = up_pos

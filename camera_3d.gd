extends Camera3D
var up_pos = position
var down_pos = up_pos + Vector3.DOWN * 20

@onready var pivot: Node3D = $".."


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		pivot.rotate(Vector3.UP, delta)
	if Input.is_action_pressed("ui_right"):
		pivot.rotate(Vector3.UP, -delta)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"): 
		position = down_pos
	else: 
		position = up_pos

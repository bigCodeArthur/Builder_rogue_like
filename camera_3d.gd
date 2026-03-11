extends Camera3D

var MOUSE_SENSITIVITY = 0.005
var up_pos = Vector3.ZERO
var down_pos = up_pos + Vector3.DOWN * 100
var cam_move : bool = false
var cam_pan : bool = false

@onready var pivot_y: Node3D = $"../.."
@onready var pivot_x: Node3D = $".."


func _process(_delta: float) -> void:
	if Input.is_action_pressed("cam_move"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cam_move = true

	elif Input.is_action_just_released("cam_move"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cam_move = false

	if Input.is_action_pressed("shift"): cam_pan = true
	else: cam_pan = false

	if Input.is_action_pressed("ui_accept"): pivot_y.position = up_pos
	else: pivot_y.position = down_pos

	if Input.is_action_just_pressed("zoom_in"): position.z -= 3
	if Input.is_action_just_pressed("zoom_out"): position.z += 3
	position.z = clamp(position.z, 3, 30)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and cam_move:
		if not cam_pan:
			pivot_y.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			pivot_x.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			pivot_x.rotation.x = clamp(
				pivot_x.rotation.x, 
				deg_to_rad(-90), 
				deg_to_rad(90)
			);
		else: 
			pivot_x.position.y += event.relative.y * MOUSE_SENSITIVITY
	

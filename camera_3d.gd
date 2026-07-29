extends Node3D

var MOUSE_SENSITIVITY = 0.005
var cam_move : bool = false
var cam_pan : bool = false

@export var baker: Baker
@export var editor_space: Node3D

@export var target: Target
@export var creator: Creator

@onready var camera: Camera3D = $Pivot_x/Camera3D
@onready var pivot_y: Node3D  = self
@onready var pivot_x: Node3D  = $Pivot_x


func _ready() -> void:
	pivot_y.position = creator.position
	editor_space.position = creator.position


func _process(_delta: float) -> void:
	if Input.is_action_pressed("cam_move"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cam_move = true

	elif Input.is_action_just_released("cam_move"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cam_move = false

	if Input.is_action_pressed("shift"): cam_pan = true
	else: cam_pan = false

	if Input.is_action_just_pressed("zoom_in"):  camera.position.z -= 1
	if Input.is_action_just_pressed("zoom_out"): camera.position.z += 1
	camera.position.z = clamp(camera.position.z, 5, 30)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and cam_move:
		if not cam_pan:
			pivot_y.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			pivot_x.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			pivot_x.rotation.x = clamp(pivot_x.rotation.x, -PI/2, (PI/2)-0.3);
		else:
			pivot_x.position.y += event.relative.y * (MOUSE_SENSITIVITY * 3)
			pivot_x.position.y = clamp(pivot_x.position.y, 0, 30)


func _on_mode_switch_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		baker.bake()
		pivot_y.position = target.position
		editor_space.position = target.position
	else:
		pivot_y.position = creator.position
		editor_space.position = creator.position

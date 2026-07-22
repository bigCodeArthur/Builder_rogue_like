class_name Target extends Node3D

@onready var mesh_instance : MeshInstance3D = $Skeleton3D/Mesh
@onready var look_at_mod   : LookAtModifier3D = $Skeleton3D/LookAt
@onready var ik            : IterateIK3D = $Skeleton3D/IK
@onready var skeleton      : Skeleton3D = $Skeleton3D
@onready var target        : Marker3D = $Target


var dir = -1
func _process(_delta: float) -> void:
	target.position.x += dir / 10.0

	if target.position.x < -10 : dir =  1
	if target.position.x > 10  : dir = -1


func test():
	look_at_mod.bone_name = "upper_body"
	look_at_mod.target_node = look_at_mod.get_path_to(target)

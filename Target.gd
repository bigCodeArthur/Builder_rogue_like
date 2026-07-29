class_name Target extends Node3D

@onready var mesh_instance : MeshInstance3D = $Skeleton3D/Mesh
@onready var skeleton      : Skeleton3D = $Skeleton3D

@onready var look_at_mod   : LookAtModifier3D = $Skeleton3D/LookAt
@onready var ik_mod        : FABRIK3D = $Skeleton3D/IK
@onready var ct_mod        : CopyTransformModifier3D = $Skeleton3D/CopyTransformModifier3D


@onready var target        : Marker3D = $Target
@onready var target_left   : Marker3D = $Target_left
@onready var target_right  : Marker3D = $Target_right

var upper_dir = -1
var legs_dir  =  1


func _process(delta: float) -> void:
	target.position.x += upper_dir * delta * 20

	if target.position.x < -10 : upper_dir =  1
	if target.position.x > 10  : upper_dir = -1

	target_left.position.y += legs_dir * delta * 3
	target_right.position.y = target_left.position.y

	if target_left.position.y <= 0.6: legs_dir = 1
	if target_left.position.y > 4: legs_dir = -1


func set_modifiers() -> void:
	look_at_mod.bone_name   = "upper_body"
	look_at_mod.target_node = look_at_mod.get_path_to(target)

	ct_mod.clear_setting()
	ct_mod.set_setting_count(2)

	ct_mod.set_apply_bone_name(0, "Left_foot")
	ct_mod.set_reference_type(0, ct_mod.ReferenceType.REFERENCE_TYPE_NODE)
	ct_mod.set_reference_node(0, ct_mod.get_path_to(target_left))

	ct_mod.set_copy_position(0, false)
	ct_mod.set_copy_rotation(0, true)
	ct_mod.set_copy_scale(0, false)

	ct_mod.set_apply_bone_name(1, "Right_foot")
	ct_mod.set_reference_type(1, ct_mod.ReferenceType.REFERENCE_TYPE_NODE)
	ct_mod.set_reference_node(1, ct_mod.get_path_to(target_right))

	ct_mod.set_copy_position(1, false)
	ct_mod.set_copy_rotation(1, true)
	ct_mod.set_copy_scale(1, false)

	ik_mod.clear_settings()
	ik_mod.set_setting_count(2)

	ik_mod.set_target_node(0, ik_mod.get_path_to(target_left))
	ik_mod.set_root_bone_name(0, "Left")
	ik_mod.set_end_bone_name(0, "Left_foot")

	ik_mod.set_target_node(1, ik_mod.get_path_to(target_right))
	ik_mod.set_root_bone_name(1, "Right")
	ik_mod.set_end_bone_name(1, "Right_foot")

class_name Segment extends Node

enum Type {LIMB, HAND, FOOT, LOWER_BODY, UPPER_BODY, WEAPON} 

@export var parent_joint: Joint
@export var type: Type

var meshes     : Array[Mesh]
var transforms : Array[Transform3D]
var bone_id    : int  = -1


func _ready() -> void:
	var mesh_instances: Array[MeshInstance3D]
	mesh_instances.assign(find_children("", "MeshInstance3D", true, false))

	for instance in mesh_instances:
		if instance is MeshInstance3D and not instance.mesh == null:
			append(instance.mesh, instance.global_transform)


func append(mesh: Mesh, transform: Transform3D) -> void:
	meshes.append(mesh)
	transforms.append(transform)


func size() -> int:
	return min(meshes.size(), transforms.size())


func get_parent_bone() -> int:
	if parent_joint.get_parent_segment():
		return parent_joint.get_parent_segment().bone_id
	else:
		return -1


func get_parent_transform() -> Transform3D:
	if parent_joint:
		return parent_joint.global_transform
	else:
		return Transform3D.IDENTITY


func get_limb() -> Array[Segment]:
	var segment: Segment = self
	var limb: Array[Segment] = []

	var LB = segment.Type.LOWER_BODY
	var UB = segment.Type.UPPER_BODY

	while not segment.type == LB or segment.type == UB:
		limb.append(segment)
		if not parent_joint: break # in case of floating limb
		segment = segment.parent_joint.get_parent_segment()

	limb.reverse()
	return limb

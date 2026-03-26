class_name Baker extends Node

const BASE_CREATION_MATERIAL = preload("uid://brvlbsaj0tib6")

var dt : MeshDataTool = MeshDataTool.new()
var st : SurfaceTool = SurfaceTool.new()

@export var creator : Creator
@export var target : Target

@onready var target_skeleton : Skeleton3D = $"../Target/Skeleton3D"
@onready var target_mesh: MeshInstance3D = $"../Target/Skeleton3D/Target_mesh"


class Segment extends Object:
	var meshes: Array[Mesh]
	var transforms: Array[Transform3D]

	static func from_mesh_instances(mesh_instances: Array[MeshInstance3D]) -> Segment:
		var segment : Segment = new()

		for instance in mesh_instances:
			if instance is MeshInstance3D and not instance.mesh == null:
				segment.append(instance.mesh, instance.global_transform)

		return segment

	func _init(in_meshes: Array[Mesh] = [], in_transforms: Array[Transform3D] = []) -> void:
		meshes = in_meshes
		transforms = in_transforms

	func append(m: Mesh, t: Transform3D) -> void:
		meshes.append(m)
		transforms.append(t)

	func size() -> int:
		return min(meshes.size(), transforms.size())


func bake() -> void:
	bake_each_segment()


func bake_each_segment() -> void:
	var baked_mesh := ArrayMesh.new()
	target_skeleton.clear_bones()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for segment_node in [creator]: # TODO: get all segment nodes.
		var bone_id := target_skeleton.add_bone("first_bone_baby!!!")
		target_skeleton.set_bone_global_pose(bone_id, creator.transform) 
		target_skeleton.set_bone_parent(bone_id, bone_id - 1)
		var mesh_instances := get_segment_mesh_instances(segment_node)
		var segment := Segment.from_mesh_instances(mesh_instances)
		baked_mesh = segment_to_mesh_with_bone(baked_mesh, segment, bone_id)

	target.set_mesh(baked_mesh)
	Helper.save_as_gltf(target)


func get_segment_mesh_instances(segment: Node3D) -> Array[MeshInstance3D]:
	var mesh_instances: Array[MeshInstance3D]
	#TODO: get all piece nodes, not children of other segments.
	mesh_instances.assign(segment.find_children("", "MeshInstance3D", true, false))
	return mesh_instances


func segment_to_mesh_with_bone(mesh: ArrayMesh, segment: Segment, bone: int) -> ArrayMesh:
	var offset := creator.global_transform.affine_inverse()

	for m in segment.size():
		bake_mesh_to_bone(segment.meshes[m], segment.transforms[m], bone, offset)

	st.generate_tangents()
	return st.commit(mesh)


func bake_mesh_to_bone(
	mesh: Mesh, 
	transform: Transform3D, 
	bone: int, 
	offset: Transform3D
) -> void:
	var position_offset := offset * transform
	var normal_offset := position_offset.basis.inverse().transposed()

	dt.create_from_surface(mesh as ArrayMesh, 0)
	st.set_material(BASE_CREATION_MATERIAL)

	for face in dt.get_face_count(): for corner_index in 3: # for all faces and verts.
		var vert := dt.get_face_vertex(face, corner_index)
		var new_normal := normal_offset * dt.get_vertex_normal(vert)
		var new_vertex := position_offset * dt.get_vertex(vert)

		st.set_color(Color(0.436, 0.123, 0.124, 1))
		st.set_bones(PackedInt32Array([bone, 0, 0, 0]))
		st.set_weights(PackedFloat32Array([1, 0, 0, 0]))
		st.set_uv(dt.get_vertex_uv(vert))
		st.set_normal(new_normal.normalized())
		st.add_vertex(new_vertex)

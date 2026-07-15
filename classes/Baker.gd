class_name Baker extends Node

const BASE_CREATION_MATERIAL = preload("uid://brvlbsaj0tib6")

var dt : MeshDataTool = MeshDataTool.new()
var st : SurfaceTool  = SurfaceTool.new()

## creator is a node that allows the player to create a creation.
@export var creator: Creator

## here is where the player created creation will be baked to as mesh with skeleton.
@export var target: Target

@onready var target_skeleton : Skeleton3D = $"../Target/Skeleton3D"
@onready var target_mesh     : MeshInstance3D = $"../Target/Skeleton3D/Mesh"
@onready var target_algo     : FABRIK3D = $"../Target/Skeleton3D/Algo"


func bake() -> void:
	var baked_mesh := ArrayMesh.new()
	var segments: Array[Segment] = [creator.get_node("lower_body")]

	target_skeleton.clear_bones()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for child in creator.get_children():
		if not child is Segment: 
			continue

		var segment := child as Segment
		var HAND = segment.Type.HAND
		var FOOT = segment.Type.FOOT

		if segment.type == HAND or segment.type == FOOT:
			segments.append_array(segment.get_limb())

	for i in segments.size(): 
		segments[i].bone_id = i

	for segment in segments:
		var bone_id := target_skeleton.add_bone(segment.name)
		target_skeleton.set_bone_parent(bone_id, segment.get_bone_parent())
		target_skeleton.set_bone_global_pose(bone_id, segment.get_parent_transform())
		baked_mesh = segment_to_mesh_with_bone(baked_mesh, segment, bone_id)

	target.set_mesh(baked_mesh)
	Helper.save_as_gltf(target)


func segment_to_mesh_with_bone(mesh: ArrayMesh, segment: Segment, bone: int) -> ArrayMesh:
	var offset := creator.global_transform.affine_inverse()
	for part in segment.size():
		bake_mesh_to_bone(
			segment.meshes[part], 
			bone, 
			segment.transforms[part], 
			offset
		)
	st.generate_tangents()
	return st.commit(mesh)


func bake_mesh_to_bone(
	mesh: Mesh, 
	bone: int, 
	transform: Transform3D = Transform3D.IDENTITY, 
	offset: Transform3D = Transform3D.IDENTITY
) -> void:
	var position_offset := offset * transform
	var normal_offset := position_offset.basis.inverse().transposed()

	dt.create_from_surface(mesh, 0)
	st.set_material(BASE_CREATION_MATERIAL)

	for face in dt.get_face_count(): for corner_index in 3: # for all faces and their verts.
		var vert := dt.get_face_vertex(face, corner_index)
		var new_normal := normal_offset * dt.get_vertex_normal(vert)
		var new_vertex := position_offset * dt.get_vertex(vert)

		st.set_color(Color(0.745, 0.745, 1.257, 1.0))
		st.set_bones(PackedInt32Array([bone, 0, 0, 0]))
		st.set_weights(PackedFloat32Array([1.0, 0.0, 0.0, 0.0]))
		st.set_uv(dt.get_vertex_uv(vert))
		st.set_normal(new_normal.normalized())
		st.add_vertex(new_vertex)

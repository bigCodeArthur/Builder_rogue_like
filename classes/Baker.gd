class_name Baker extends Node

const BASE_CREATION_MATERIAL = preload("uid://brvlbsaj0tib6")

var dt : MeshDataTool = MeshDataTool.new()
var st : SurfaceTool  = SurfaceTool.new()

## creator is a node that allows the player to create a creation.
@export var creator: Creator

## here is where the player created creation will be baked to as mesh with skeleton.
@export var target: Target


func bake() -> void:
	var baked_mesh := ArrayMesh.new()
	var segments: Array[Segment] = [
		creator.get_node("lower_body"),
		creator.get_node("upper_body")
	]

	st.begin(Mesh.PRIMITIVE_TRIANGLES); target.skeleton.clear_bones()
	segments.append_array(creator.get_segments_limb_ordered())

	for segment in segments:
		segment.bone_id = target.skeleton.add_bone(segment.name)
		target.skeleton.set_bone_parent(segment.bone_id, segment.get_parent_bone())
		target.skeleton.set_bone_global_rest(segment.bone_id, segment.get_parent_transform())
		baked_mesh = segment_to_mesh_with_bone(baked_mesh, segment, segment.bone_id)

	target.skeleton.reset_bone_poses()

	target.mesh_instance.mesh      = baked_mesh
	target.mesh_instance.skin      = null # reset skin so godot can regenerate it
	target.mesh_instance.skeleton  = target.mesh_instance.get_path_to(target.skeleton)

	target.look_at_mod.bone_name   = "upper_body"
	target.look_at_mod.target_node = target.look_at_mod.get_path_to(target.target)


func segment_to_mesh_with_bone(
	mesh: ArrayMesh, 
	segment: Segment, 
	bone: int
) -> ArrayMesh:
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
	transform: Transform3D, 
	offset: Transform3D
) -> void:
	var position_offset := offset * transform
	var normal_offset := position_offset.basis.inverse().transposed()

	dt.create_from_surface(mesh, 0)
	st.set_material(BASE_CREATION_MATERIAL)

	for face in dt.get_face_count(): for corner_index in 3:
		var vert := dt.get_face_vertex(face, corner_index)
		var new_normal := normal_offset * dt.get_vertex_normal(vert)
		var new_vertex := position_offset * dt.get_vertex(vert)

		st.set_color(Color(0.745, 0.745, 1.257, 1.0))
		st.set_bones(PackedInt32Array([bone, 0, 0, 0]))
		st.set_weights(PackedFloat32Array([1.0, 0.0, 0.0, 0.0]))
		st.set_uv(dt.get_vertex_uv(vert))
		st.set_normal(new_normal.normalized())
		st.add_vertex(new_vertex)

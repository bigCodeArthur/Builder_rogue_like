class_name Baker extends Node

const BASE_CREATION_MATERIAL = preload("uid://brvlbsaj0tib6")

var dt : MeshDataTool = MeshDataTool.new()
var st : SurfaceTool = SurfaceTool.new()

@export var creator : Creator
@export var target : Target

@onready var skeleton : Skeleton3D = $"../Target/Skeleton3D"
@onready var target_mesh: MeshInstance3D = $"../Target/Skeleton3D/Target_mesh"


class Segment extends Object:
	var meshes: Array[Mesh]
	var transforms: Array[Transform3D]

	func _init(in_meshes: Array[Mesh] = [], in_transforms: Array[Transform3D] = []) -> void:
		meshes = in_meshes
		transforms = in_transforms

	func append(m: Mesh, t: Transform3D) -> void:
		meshes.append(m)
		transforms.append(t)

	func size() -> int:
		return meshes.size()


func bake() -> void:
	var segment : Segment = Segment.new()

	for instance in creator.find_children("", "MeshInstance3D", true, false):
		if instance is MeshInstance3D and not instance.mesh == null:
			segment.append(instance.mesh, instance.global_transform)

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	target.set_mesh(bake_segment_to_bone(segment.meshes, segment.transforms, 0))
	Helper.save_as_gltf(target)


func bake_segment_to_bone(
	c_meshes: Array[Mesh], 
	c_transforms: Array[Transform3D], 
	bone_id: int
) -> ArrayMesh:
	var offset := creator.global_transform.affine_inverse()
	for m in c_meshes.size(): bake_mesh_to_bone(c_meshes[m], c_transforms[m], bone_id, offset)
	st.generate_tangents()
	return st.commit()


func bake_mesh_to_bone(
	c_mesh: Mesh, 
	c_transform: Transform3D,
	bone_id: int, 
	offset: Transform3D
) -> void:
	var position_offset := offset * c_transform
	var normal_offset := position_offset.basis.inverse().transposed()
	var color := Color(0.219, 0.308, 0.076, 1.0)

	dt.create_from_surface(c_mesh as ArrayMesh, 0)
	st.set_material(BASE_CREATION_MATERIAL)

	# go through each tri and through each vertex of that tri
	for face in dt.get_face_count(): for corner_index in 3:
		var vert := dt.get_face_vertex(face, corner_index)
		var new_normal := normal_offset * dt.get_vertex_normal(vert)
		var new_vertex := position_offset * dt.get_vertex(vert)

		st.set_color(color) # TODO: test value
		st.set_bones(PackedInt32Array([bone_id, 0, 0, 0]))
		st.set_weights(PackedFloat32Array([1, 0, 0, 0]))
		st.set_uv(dt.get_vertex_uv(vert))
		st.set_normal(new_normal.normalized())
		st.add_vertex(new_vertex)

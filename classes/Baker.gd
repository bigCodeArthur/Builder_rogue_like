class_name Baker extends Node3D

@export var creator : Creator
@export var target : Target

var dt : MeshDataTool = MeshDataTool.new()
var st : SurfaceTool = SurfaceTool.new()

@onready var target_mesh: MeshInstance3D = $"../Target/Skeleton3D/Target_mesh"

func bake() -> ArrayMesh:
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var skeleton := Skeleton3D.new()
	var joints : Array[Joint] = find_children("", "Joint") as Array[Joint]
	var meshes = creator.find_children("", "MeshInstance3D", true, false)

	for joint in joints: bake_segment_to_bone(meshes, skeleton.add_bone(joint.bone_name))

	return ArrayMesh.new()


func _ready() -> void:
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var meshes = creator.find_children("", "MeshInstance3D", true, false)
	target.set_mesh(bake_segment_to_bone(meshes, 0))

	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	gltf_doc.append_from_scene(target, gltf_state)
	gltf_doc.write_to_filesystem(gltf_state, "res://gltfs/test.glb")


func _physics_process(delta: float) -> void:
	creator.rotate(Vector3.UP, delta)
	target.rotate(Vector3.UP, delta)


## turn a group of meshes into a single one, 
## with the influence of a single given bone.
func bake_segment_to_bone(meshes: Array, bone_id: int) -> ArrayMesh:
	var creator_inverse := creator.global_transform.affine_inverse()
	for mesh_instance in meshes as Array[MeshInstance3D]:
		var offset := creator_inverse * mesh_instance.global_transform
		var normal_mat := offset.basis.inverse().transposed()
		dt.create_from_surface(mesh_instance.mesh as ArrayMesh, 0)
		st.set_material(target_mesh.mesh.material)
		# go through each tri and through each vertex of that tri
		for face in dt.get_face_count(): for corner in 3:
			var vert := dt.get_face_vertex(face, corner)
			var new_normal := normal_mat * dt.get_vertex_normal(vert)
			var new_vertex := offset * dt.get_vertex(vert)
			st.set_color(Color(0.0, 0.523, 0.33, 1.0)) # test value
			st.set_bones(PackedInt32Array([bone_id, 0, 0, 0]))
			st.set_weights(PackedFloat32Array([1, 0, 0, 0]))
			st.set_uv(dt.get_vertex_uv(vert))
			st.set_normal(new_normal.normalized())
			st.add_vertex(new_vertex)
	st.generate_tangents()
	return st.commit()

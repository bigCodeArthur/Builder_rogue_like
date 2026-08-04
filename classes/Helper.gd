class_name Helper extends Object

static func save_as_gltf(t: Node3D) -> void:
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	gltf_doc.append_from_scene(t, gltf_state)
	gltf_doc.write_to_filesystem(gltf_state, "user://test.glb")

static func save_as_scn(node: Node3D):
	var packed := PackedScene.new()
	packed.pack(node)
	ResourceSaver.save(packed, "user://character.scn")


static func set_bone_global_rest(
	skltn: Skeleton3D, 
	bone: int, 
	global_rest: Transform3D
) -> void:
	var parent := skltn.get_bone_parent(bone)

	if parent == -1: 
		skltn.set_bone_rest(bone, global_rest)
	else:
		var parent_global_rest := skltn.get_bone_global_rest(parent)
		var local_rest := parent_global_rest.affine_inverse() * global_rest
		skltn.set_bone_rest(bone, local_rest)

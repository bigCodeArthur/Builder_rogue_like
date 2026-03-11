class_name Helper extends Object

static func save_as_gltf(t: Node3D) -> void:
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	gltf_doc.append_from_scene(t, gltf_state)
	gltf_doc.write_to_filesystem(gltf_state, "user://test.glb")

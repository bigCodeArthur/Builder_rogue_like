extends Skeleton3D


func set_bone_global_rest(bone: int, global_rest: Transform3D) -> void:
	var parent := get_bone_parent(bone)

	if parent == -1:
		set_bone_rest(bone, global_rest)
	else:
		var parent_global_rest := get_bone_global_rest(parent)
		var local_rest := parent_global_rest.affine_inverse() * global_rest
		set_bone_rest(bone, local_rest)

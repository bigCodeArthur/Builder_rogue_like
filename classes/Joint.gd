class_name Joint extends Piece

@export var bone_name : String

func nextJoints() -> Array[Joint]:
	var output : Array[Joint] = []
	for child in get_children(): if child is Joint: output.append(child)
	return output

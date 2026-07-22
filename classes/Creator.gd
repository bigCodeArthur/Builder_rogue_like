class_name Creator extends Node3D


func is_terminal(segment: Segment):
	var is_foot: bool = segment.type == Segment.Type.FOOT
	var is_hand: bool = segment.type == Segment.Type.HAND 

	return is_foot or is_hand


func get_segments(terminal_segment: bool = false) -> Array[Segment]:
	var segments: Array[Segment] = []

	for child in get_children(true): if child is Segment: segments.append(child)

	if terminal_segment: return segments.filter(is_terminal)
	else: return segments


func get_segments_limb_ordered() -> Array[Segment]:
	var segments: Array[Segment]

	for segment in get_segments(true):
		segments.append_array(segment.get_limb())

	return segments

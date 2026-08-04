class_name Creator extends Node3D


func is_terminal(segment: Segment) -> bool:
	var is_foot := segment.type == Segment.Type.FOOT
	var is_hand := segment.type == Segment.Type.HAND 

	return is_foot or is_hand


func get_terminal_segments() -> Array[Segment]:
	var segments: Array[Segment] = []

	for child in get_children(true):
		if child is Segment:
			segments.append(child)

	return segments.filter(is_terminal)


func get_segments_limb_ordered() -> Array[Segment]:
	var segments: Array[Segment]

	for segment in get_terminal_segments(): 
		segments.append_array(segment.get_limb())

	return segments

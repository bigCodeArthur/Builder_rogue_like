class_name Joint extends Node3D

func get_parent_segment() -> Segment: 
	return get_parent() as Segment

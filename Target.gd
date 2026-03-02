class_name Target extends Node3D

@onready var target_mesh_instance: MeshInstance3D = $Skeleton3D/Target_mesh


func set_mesh(value : Mesh) -> void:
	find_child("Target_mesh").mesh = value


func get_mesh() -> Mesh:
	return target_mesh_instance.mesh

class_name Target extends Node3D

@onready var mesh: MeshInstance3D = $Skeleton3D/Target_mesh
@onready var skeleton: Skeleton3D = $Skeleton3D


func set_mesh(value : Mesh) -> void:
	mesh.mesh = value


func get_mesh() -> Mesh:
	return mesh.mesh

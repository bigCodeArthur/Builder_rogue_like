@tool class_name ConnectionPoint extends MeshInstance3D

enum Type {IN_STRUCT, OUT_STRUCT, IN_POWER, OUT_POWER}

@export var size_horizontal := true
@export_range(1, 20) var size: int = 1
@export var type: Type = Type.IN_STRUCT

var connected: ConnectionPoint
var piece: Piece:
	get: return owner as Piece
	set(_none): print("bruh")

# TODO: CHECK COLLISION

# TODO: UPDATE MESH ON CHANGES

# 

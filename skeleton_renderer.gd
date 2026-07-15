extends MeshInstance3D

@export var skltn: Skeleton3D
@export var line_color: Color = Color.GREEN

var immediate_mesh := ImmediateMesh.new()
var material := ORMMaterial3D.new()

func _ready():
	mesh = immediate_mesh

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = true

	material_override = material


func _physics_process(_delta):
	if skltn == null or skltn.get_bone_count() == 0: return

	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	for bone in skltn.get_bone_count():
		var parent := skltn.get_bone_parent(bone)
		if parent == -1: continue
		var bone_transform := skltn.global_transform * skltn.get_bone_global_pose(bone)
		var parent_transform := skltn.global_transform * skltn.get_bone_global_pose(parent)

		immediate_mesh.surface_set_color(line_color)
		immediate_mesh.surface_add_vertex(parent_transform.origin)
		immediate_mesh.surface_add_vertex(bone_transform.origin)

	immediate_mesh.surface_end()

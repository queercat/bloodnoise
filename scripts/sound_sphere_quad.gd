extends MeshInstance3D

var target_sphere: Node3D

func get_material():
	return get_active_material(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# get_active_material(0).set_shader_parameter("start_point", target_sphere.transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if target_sphere == null:
		#queue_free()
		#return
	#
	#get_active_material(0).set_shader_parameter("radius", target_sphere.radius)

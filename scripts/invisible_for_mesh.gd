extends MeshInstance3D

@export var reveal_distance: float = 10
var material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = material_override 
	if material != null:
		material.set_shader_parameter("reveal_distance", reveal_distance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if material != null:
		GameManager.feed_material_spheres(material)

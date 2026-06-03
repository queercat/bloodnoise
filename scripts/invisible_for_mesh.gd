extends MeshInstance3D

var material: Material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = material_override 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameManager.feed_material_spheres(material)

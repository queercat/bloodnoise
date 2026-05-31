extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material_overlay.set_shader_parameter("character_position", GameManager.player_manager.body.position)

extends Node3D

@export var end_area: Area3D
@export var shader_mesh: MeshInstance3D
var uber_shader: ShaderMaterial

func _init():
	GameManager.has_started = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	uber_shader = shader_mesh.get_active_material(0)
	GameManager.uber_shader = uber_shader
	GameManager.__ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

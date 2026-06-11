extends Node3D

@export var is_puzzle_coffin: bool = false

@onready var coffin_body = $"Coffin_Body"
@onready var coffin_lid = $"Coffin_Lid"
@onready var coffin_lid_collider = $"Coffin_Lid/StaticBody3D"
@onready var lever_transform = $"Coffin_Lever_Transform" 

func _ready() -> void:
	if is_puzzle_coffin:
		make_puzzle_coffin()
	else:
		coffin_lid.material_override = null

func make_puzzle_coffin():
	lever_transform.show()
	coffin_lid_collider.hide()
	var lid_material: ShaderMaterial = coffin_lid.material_override
	lid_material.set_shader_parameter("is_enabled", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

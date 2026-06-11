extends Node3D

@export var zone: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.register_warp_zone(self)

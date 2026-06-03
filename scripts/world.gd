extends Node3D

@export var end_area: Area3D

func _init():
	GameManager.has_started = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.__ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

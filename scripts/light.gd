extends Node3D

@export var light: OmniLight3D

# when sound sphere hits me, turn on!

func turn_on_light():
	light.light_energy = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	turn_on_light()

func _on_area_3d_body_entered(body: Node3D) -> void:
	turn_on_light()

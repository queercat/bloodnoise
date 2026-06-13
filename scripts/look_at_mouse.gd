extends Node3D

var speen = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speen += delta
	var mouse_position = get_viewport().get_mouse_position()
	look_at(get_viewport().get_camera_3d().position);
	rotation_degrees.y = (mouse_position.x / 360) - 30
	rotation_degrees.x = -(mouse_position.y / 360) + 15
	rotation_degrees.z = speen

extends Node3D

# Rotation in radians
@export var sprite_rotation : float = 0.0
# Upright position (still rotateable)
@export var y_billboard = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get camera coordinates
	var cam : Camera3D = get_viewport().get_camera_3d()
	var look_pos : Vector3 = cam.global_position
	
	# If billboard should be upright, look at camera, but at the height of the object itself
	if y_billboard:
		look_pos.y = global_position.y
	# First look directly at the camera, then rotate around own axis
	# Note: as an up axis here is camera's up, but one might want to use Vector3.UP instead
	look_at(look_pos, cam.global_transform.basis.y)
	rotate_object_local(Vector3.UP, sprite_rotation)

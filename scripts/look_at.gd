extends Camera3D

@export var target: Node3D
@export var shake_intensity: float = 0
var random = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_intensity > 0:
		position -= random
		random = Vector3(randf(), randf(), randf()) * shake_intensity
		position += random
	
	look_at(target.global_position)
	

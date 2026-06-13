extends Camera3D

@export var target: Node3D
var random = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position -= random
	random = Vector3(randf(), randf(), randf())
	look_at(target.global_position)
	position += random

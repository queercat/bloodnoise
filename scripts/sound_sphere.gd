extends Node3D

@export var growth_speed: float = 1
@export var boundary: float = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale += Vector3.ONE * growth_speed * delta

	if scale.z >= boundary:
		self.queue_free()

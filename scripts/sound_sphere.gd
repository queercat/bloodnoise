extends Node3D

@export var growth_speed: float = 1
@export var boundary: float = 10
var radius = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	scale += Vector3.ONE * growth_speed * delta
	radius = scale.x
	if radius >= boundary:
		GameManager.delete_sound_sphere(self)
		self.queue_free()

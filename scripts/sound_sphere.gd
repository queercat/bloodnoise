extends Node3D

@export var growth_speed: float = 2000000
@export var maximum_radius: float = 50
@export var color: Color = Color.WHITE
var radius = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	scale += Vector3.ONE * growth_speed * delta
	radius = scale.x
	if radius >= maximum_radius:
		GameManager.delete_sound_sphere(self)
		self.queue_free()

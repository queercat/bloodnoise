extends Node3D

@export var growth_speed: float = 2000000
@export var max_radius: float = 50
@export var color: Color = Color.WHITE

var radius = 0
var collapsing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	scale += Vector3.ONE * growth_speed * delta
	radius = scale.x
		
	if radius >= max_radius:
		collapsing = true
		radius = 0
	if radius <= 0:
		GameManager.delete_sound_sphere(self)
		self.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		pass

extends Node3D

class_name Collectable
@export var collectable_resource: Resource
@export var collection_zone: Area3D
var target = null

func collect():
	target = GameManager.player_manager.body.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collection_zone.body_entered.connect(handle_body_entered)

func handle_body_entered(body: Node3D):
	if body.get_parent().name == "Pawn":
		collect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(Vector3.UP, delta)
	if target != null:
		lerp(position, target, .1)

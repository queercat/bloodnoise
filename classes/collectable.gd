extends Node3D

class_name Collectable
@export var collectable_resource: Resource
@export var collection_zone: Area3D

func collect():
	GameManager.give_player_item(collectable_resource)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collection_zone.body_entered.connect(handle_body_entered)

func handle_body_entered(body: Node3D):
	if body.get_parent().name == "Pawn":
		collect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

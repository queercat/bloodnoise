extends Node3D

class_name Collectable
@export var collectable_resource: Resource
@export var collection_zone: Area3D

func collect():
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", GameManager.player_manager.body.global_position, 1)
	await t.finished
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
	rotate(Vector3.UP, delta)

extends Node

var player_items: Array[CollectableResource] = []

func give_player_item(resource: CollectableResource):
	player_items.push_back(resource)
	print("got %s" % resource.collectable_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

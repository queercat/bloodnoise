extends Node

var player_items: Array[CollectableResource] = []
var ui: GameUI
var player_manager: PlayerManager
var write_mutex: Mutex = Mutex.new()

signal LockUnlocked(name: String)

func unlocked_lock(name: String):
	LockUnlocked.emit(name)

func does_player_have_item(name: String):
	return player_items.any(func (v: CollectableResource): return v.collectable_name == name)

func consume_player_item(name: String):
	write_mutex.lock()
	var index = player_items.find_custom(func (v: CollectableResource): return v.collectable_name == name)
	assert(index >= 0, "Player does NOT have that item.")
	player_items.remove_at(index)
	write_mutex.unlock()

func give_player_item(resource: CollectableResource):
	player_items.push_back(resource)
	print("got %s" % resource.collectable_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node3D

@export var rows: int = 10
@export var cols: int = 10
@export var x_offset: float = 10
@export var y_offset: float = 10
@export var maus: Node

var total_levers = 3
var levers_toggled = 0

@onready var spawn_node: Node3D = $"node"
var coffin_prefab: PackedScene = preload("res://prefabs/coffin.tscn")
var coffins = []


func handle_lever(tag, state):
	if tag == "coffinLever" and state == true:
		levers_toggled += 1
	
	if levers_toggled == total_levers:
		maus.rise()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.LeverToggled.connect(handle_lever)
	for idx in rows:
		for idy in cols:
			var position_offset = Vector3(x_offset * idx, 0, y_offset * idy)
			var instance: Node3D = coffin_prefab.instantiate()
			instance.position = spawn_node.position + position_offset
			coffins.push_back(instance)
	
	var used = {}
	
	for pinkie in total_levers:
		var idx = randi_range(0, coffins.size() - 1)
		while idx in used:
			idx = randi_range(0, coffins.size() - 1)
		used[idx] = true
		var coffin = coffins[idx]
		coffin.is_puzzle_coffin = true
		
	
	for coffin in coffins:
		add_child(coffin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

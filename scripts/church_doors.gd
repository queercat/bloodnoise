extends Node3D

@export var door_L: Node3D
@export var door_R: Node3D
@export var open_seconds : float = 2.5
@export var state = false
@export var lever_name: String
var rot = 0
var tween

func change_state(state):
	rot = 90 if state else 0
		
	tween = 	create_tween()
	tween.tween_property(door_L, "rotation_degrees", Vector3(0, -rot, 0), open_seconds)
	tween.parallel().tween_property(door_R, "rotation_degrees", Vector3(0, rot, 0), open_seconds)

func handle_event(name, state):
	if name == lever_name:
		change_state(state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.LeverToggled.connect(handle_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

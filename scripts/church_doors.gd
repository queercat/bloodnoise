extends Node3D

@export var door_L: Node3D
@export var door_R: Node3D
@export var open_seconds : float = 2.5

var rot = 0
var tween

func toggle_open():
	rot = 90 if rot == 0 else 0
		
	tween = 	create_tween()
	tween.tween_property(door_L, "rotation_degrees", Vector3(0, -rot, 0), open_seconds)
	tween.parallel().tween_property(door_R, "rotation_degrees", Vector3(0, rot, 0), open_seconds)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_open()
	await get_tree().create_timer(4).timeout
	toggle_open()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
